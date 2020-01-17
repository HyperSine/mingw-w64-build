#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

#define WIN_MAX_ENV _MAX_ENV
#define WIN_MAX_PATH 32767
#define GDB_PYTHON_RELATIVE_PATH L"..\\opt\\bin"
#define GDB_ORIGIN_NAME L"gdb.origin.exe"

#define SAFE_FREE(p) { free((p)); (p) = NULL; }

int wmain(int argc, PWSTR argv[]) {
    DWORD ReturnVal;
    PWSTR lpszOldPathEnv = malloc(WIN_MAX_ENV * sizeof(WCHAR));
    PWSTR lpszGdbHome = malloc(WIN_MAX_PATH * sizeof(WCHAR));
    PWSTR lpszGdbPythonHome = malloc(WIN_MAX_PATH * sizeof(WCHAR));
    PWSTR lpszNewPathEnv = malloc(WIN_MAX_ENV * sizeof(WCHAR));
    HANDLE hGdbJob = NULL;
    PROCESS_INFORMATION ProcessInfo = { 0 };

    // Do not handle Ctrl-C in the wrapper
	SetConsoleCtrlHandler(NULL, TRUE);

    //
    // Get PATH environment variable
    //
    ZeroMemory(lpszOldPathEnv, WIN_MAX_ENV * sizeof(WCHAR));
    if (GetEnvironmentVariableW(L"PATH", lpszOldPathEnv, WIN_MAX_ENV) == 0) {
        ReturnVal = GetLastError();
        goto ON_ERROR;
    }

    //
    // Get path where GDB locates
    //
    ZeroMemory(lpszGdbHome, WIN_MAX_PATH * sizeof(WCHAR));
    if (GetModuleFileNameW(NULL, lpszGdbHome, WIN_MAX_PATH) == WIN_MAX_PATH) {
        ReturnVal = GetLastError();
        goto ON_ERROR;
    } else {
        *wcsrchr(lpszGdbHome, L'\\') = L'\x00';
    }

    //
    // Construct path where GDB-Python locates
    //
    ZeroMemory(lpszGdbPythonHome, WIN_MAX_PATH * sizeof(WCHAR));
    if (swprintf_s(lpszGdbPythonHome, WIN_MAX_PATH, L"%s\\%s", lpszGdbHome, GDB_PYTHON_RELATIVE_PATH) < 0) {
        ReturnVal = errno;
        goto ON_ERROR;
    }

    //
    // Set PYTHONHOME environment variable
    //
    if (SetEnvironmentVariableW(L"PYTHONHOME", lpszGdbPythonHome) == FALSE) {
        ReturnVal = GetLastError();
        goto ON_ERROR;
    }

    //
    // Add path where GDB-Python locates to PATH environment variable.
    // So that pythonXX.dll can be found and loaded.
    //
    ZeroMemory(lpszNewPathEnv, WIN_MAX_ENV * sizeof(WCHAR));
    if (swprintf_s(lpszNewPathEnv, WIN_MAX_ENV, L"%s;%s", lpszGdbPythonHome, lpszOldPathEnv) < 0) {
        ReturnVal = errno;
        goto ON_ERROR;
    }

    //
    // Update PATH environment variable
    //
    if (SetEnvironmentVariableW(L"PATH", lpszNewPathEnv) == FALSE) {
        ReturnVal = GetLastError();
        goto ON_ERROR;
    }

    //
    // Launch gdb.origin.exe
    //
    {
        PWSTR lpszCommandLine = lpszNewPathEnv;     // Reuse lpszNewPathEnv, so we don't need to malloc again.
        SIZE_T cchCommandLine = 0;

        //
        // Copy command line arguments
        //
        ZeroMemory(lpszCommandLine, WIN_MAX_PATH * sizeof(WCHAR));
        int cch = swprintf_s(lpszCommandLine, WIN_MAX_PATH, L"\"%s\\%s\" ", lpszGdbHome, GDB_ORIGIN_NAME);
        if (cch < 0) {
            ReturnVal = errno;
            goto ON_ERROR;
        } else {
            cchCommandLine += cch;
        }

        for (int i = 1; i < argc; ++i) {
            if (cchCommandLine + 1 < WIN_MAX_PATH) {
                cch = swprintf_s(lpszCommandLine + cchCommandLine, WIN_MAX_PATH - cchCommandLine, i + 1 == argc ? L"\"%s\"" : L"\"%s\" ", argv[i]);
                if (cch < 0) {
                    ReturnVal = errno;
                    goto ON_ERROR;
                } else {
                    cchCommandLine += cch;
                }
            } else {
                ReturnVal = ERROR_INSUFFICIENT_BUFFER;
                goto ON_ERROR;
            }
        }

        //
        // Setup a JobObject, so that gdb.origin.exe will be terminated if current process is killed.
        //
        hGdbJob = CreateJobObjectW(NULL, L"Gdb-Wrapper");
        if (hGdbJob == NULL) {
            ReturnVal = GetLastError();
            goto ON_ERROR;
        } else {
            JOBOBJECT_EXTENDED_LIMIT_INFORMATION jeli = { 0 };

            jeli.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
            if (SetInformationJobObject(hGdbJob, JobObjectExtendedLimitInformation, &jeli, sizeof(jeli)) == FALSE) {
                ReturnVal = GetLastError();
                goto ON_ERROR;
            }
        }

        STARTUPINFOW StartupInfo = { sizeof(STARTUPINFOW) };

        StartupInfo.dwFlags |= STARTF_USESTDHANDLES;
        StartupInfo.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
        StartupInfo.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
        StartupInfo.hStdError = GetStdHandle(STD_ERROR_HANDLE);
        if (CreateProcessW(NULL, lpszCommandLine, NULL, NULL, TRUE, 0, NULL, NULL, &StartupInfo, &ProcessInfo) == FALSE) {
            ReturnVal = GetLastError();
            goto ON_ERROR;
        }

        if (AssignProcessToJobObject(hGdbJob, ProcessInfo.hProcess) == FALSE) {
            ReturnVal = GetLastError();
            goto ON_ERROR;
        }
    }

    //
    // We don't need them anymore.
    //
    SAFE_FREE(lpszNewPathEnv);
    SAFE_FREE(lpszGdbPythonHome);
    SAFE_FREE(lpszGdbHome);
    SAFE_FREE(lpszOldPathEnv);

    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

    if (GetExitCodeProcess(ProcessInfo.hProcess, &ReturnVal) == FALSE) {
        ReturnVal = GetLastError();
        goto ON_ERROR;
    }

ON_ERROR:

    if (ProcessInfo.hThread) {
        CloseHandle(ProcessInfo.hThread);
    }

    if (ProcessInfo.hProcess) {
        CloseHandle(ProcessInfo.hProcess);
    }

    if (hGdbJob) {
        CloseHandle(hGdbJob);
    }

    SAFE_FREE(lpszNewPathEnv);
    SAFE_FREE(lpszGdbPythonHome);
    SAFE_FREE(lpszGdbHome);
    SAFE_FREE(lpszOldPathEnv);

    return ReturnVal;
}
