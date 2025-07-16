# AymurAI Installer

This repository contains the scripts to compile and build the AymurAI installer for Windows.

> **Note:** The AymurAI installer no longer installs Miniconda or LibreOffice automatically. You must install these dependencies manually before running AymurAI.

The installer includes the AymurAI application and required resources. It is built using the [Nullsoft Scriptable Install System (NSIS)](https://nsis.sourceforge.io/Main_Page). Compilation can be done on a native Windows environment or in a Docker container using [`wine`](https://www.winehq.org/).


## Repository Structure
The repository structure is as follows:

```
.
├── build
│   └── AymurAI-Installer.exe
├── .devcontainer
│   ├── devcontainer.json
│   └── Dockerfile
├── LICENSE.md
├── README.md
├── resources
│   ├── api
│   │   ├── pipelines
│   │   │   └── production
│   │   │       ├── flair-anonymizer
│   │   │       │   └── pipeline.json
│   │   │       └── full-paragraph
│   │   │           └── pipeline.json
│   │   └── static
│   │       └── logo256-text.ico
│   ├── aymurai-<VERSION>-py3-none-any.whl
│   ├── environment.yml
│   ├── install.bat
│   ├── run_server.bat
│   └── uninstall.bat
└── scripts
    ├── headers
    │   ├── install_backend.nsh
    │   ├── install_frontend.nsh
    │   └── uninstall.nsh
    └── installer.nsi
```

- The `build` directory contains the compiled installer executable.
- The `.devcontainer` directory contains configuration for the development container.
- The `resources` directory contains resources required to build the installer, such as the AymurAI wheel file and environment file.
- The `scripts` directory contains the NSIS installer script and headers.


## Getting Started

### Prerequisites

- [NSIS](https://nsis.sourceforge.io/Main_Page) (if compiling on a native Windows environment)
- [Docker](https://docs.docker.com/) (if compiling in a development container)
- [Visual Studio Code](https://code.visualstudio.com/) (if using the development container)
- [Miniconda](https://docs.anaconda.com/miniconda/) (**must be installed manually**)
- [LibreOffice](https://www.libreoffice.org/) (**must be installed manually**)

### Manual Installation of Dependencies

Before installing AymurAI, you must manually install Miniconda and LibreOffice:

1. **Download and install Miniconda for Windows:**
   - [Miniconda Download Page](https://repo.anaconda.com/miniconda/)
   - Download the latest Windows x86_64 installer and run it.

2. **Download and install LibreOffice for Windows:**
   - [LibreOffice Download Page](https://www.libreoffice.org/download/download/)
   - Download the latest Windows x86_64 MSI installer and run it.

> Ensure both Miniconda and LibreOffice are installed and available in your system before proceeding with the AymurAI installation.

### VS Code development environment
1. Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension for Visual Studio Code.
2. Open the repository in Visual Studio Code.
3. Click on the `Reopen in Container` button in the bottom right corner of the window to open the repository in a development container. Alternatively, you can run the `Dev Containers: Reopen in Container` command from the command palette (`Ctrl+Shift+P`).
4. The development container will be built and the repository will be opened in the container. This may take a few minutes. The `wine` command will be available in the container to compile the installer.


### Compiling the Installer
If you are working on a native Windows environment, you can use the NSIS compiler directly. Download the [NSIS installer](https://nsis.sourceforge.io/Download) and install it on your system. Load the `installer.nsi` script located in the `scripts` directory using the NSIS compiler and compile the installer.

If you are working in the development container, you can compile the installer using the `wine` command. Run the following command to compile the installer:

```bash
# Compile the installer
wine ~/.wine/drive_c/Program\ Files/NSIS/makensis.exe -- scripts/installer.nsi
```

The installer executable will be created in the `build` directory.


## Contributing
We welcome contributions to AymurAI! If you would like to contribute, feel free to submit a pull request with your changes or open an issue if you have any questions or suggestions.


## Contributors
- **Julián Ansaldo** - [@jansaldo](https://github.com/jansaldo) at [collective.ai](https://collectiveai.io) ([email](mailto:juli@collectiveai.io))
- **Raúl Barriga** - [@jedzill4](https://github.com/jedzill4) at [collective.ai](https://collectiveai.io) ([email](mailto:r@collectiveai.io))
- **Matías David Szlajen** - [@dblandit-git](https://github.com/dblandit-git) at [DBlandIT](https://dblandit.com/) ([email](mailto:mszlajen@dblandit.com))


## Citing AymurAI
If you use AymurAI in your research or any publication, please cite the following paper to acknowledge our work:

```bibtex
@techreport{feldfeber2022,
    author      = "Feldfeber, Ivana and Quiroga, Yasmín Belén  and Guevara, Clarissa  and Ciolfi Felice, Marianela",
    title       = "Feminisms in Artificial Intelligence: Automation Tools towards a Feminist Judiciary Reform in Argentina and Mexico",
    institution = "DataGénero",
    year        = "2022",
    url         = "https://drive.google.com/file/d/1P-hW0JKXWZ44Fn94fDVIxQRTExkK6m4Y/view"
}
```

Proper citation helps us continue developing AymurAI and supporting the community.


## License
AymurAI is open-source software licensed under the [MIT License](LICENSE.md). This license allows for modification, distribution, and private use, provided that appropriate credit is given to the original authors.
