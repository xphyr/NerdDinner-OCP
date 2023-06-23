# NERDDINNER OCP Example

This repo is a demo of taking an older MVC application and running it in a WINDOWS Container hosted in OpenShift using Windows Worker Nodes.

[NerdDinner](https://learn.microsoft.com/en-us/aspnet/mvc/overview/older-versions-1/nerddinner/introducing-the-nerddinner-tutorial) was originally hosted on CodePlex. I have made a copy of the code from [https://github.com/sixeyed/nerd-dinner](https://github.com/sixeyed/nerd-dinner) and am using this as the basis of this project. The C# code has not been changed at all from Sixeyed's copy of the code, which is listed as being an original copy of the code.

The intent is to show that using Windows containers it is possible to run code that goes back a few years.

## Requirements

* [Visual Studio 2022](https://visualstudio.microsoft.com/vs/compare/)
* OpenShift Container Platform 4.12+
	* Windows Machine Config Operator installed and working
* Windows 11 Machine with [Windows Containers configured](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-10-and-11-1)
	* If you don't have a Windows 11 license, you can [Get a Windows 11 Development Environment](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/), but you will need to enable Nested Virtualization within your VM platform
	* It is possible to install Docker for Windows without Docker Desktop. See [Windows Containers on Windows 10 or 11, without Docker Desktop](https://xphyr.net/post/windows_containers_win11/) for alternative install options.

## Building and Running the Container Locally

This example is written and tested using the mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019 base container. 

To build the Windows container from a PowerShell terminal:

```
docker build -t nd .
```

To run the start the Nerd Dinner application container:

```
docker run --name nerddinner -p 8000:80 nd
```

Once the application has started, use a web browser to open http://localhost:8000.