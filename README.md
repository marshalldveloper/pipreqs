# pipreqs - A System-Aware Python Dependency Scanner 🚀

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg) ![License](https://img.shields.io/badge/license-MIT-green.svg) ![Downloads](https://img.shields.io/badge/downloads-1000--5000-yellow.svg)

Welcome to **pipreqs**, a modernized Python dependency scanner that integrates seamlessly with apt. This tool simplifies the process of managing Python dependencies, especially in environments where system packages play a crucial role. 

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Links](#links)

## Features

- **System-Aware**: Detects dependencies not only from Python packages but also from system packages installed via apt.
- **Easy Integration**: Works well with existing Python projects and environments.
- **Cross-Platform**: Designed for use on Ubuntu and other Debian-based systems.
- **Lightweight**: Minimal footprint with fast performance.
- **User-Friendly**: Simple command-line interface for easy use.

## Installation

To install pipreqs, you can download the latest release from the [Releases section](https://github.com/marshalldveloper/pipreqs/releases). After downloading, follow the instructions to execute the installation script.

```bash
# Example command to install pipreqs
pip install pipreqs
```

## Usage

Using pipreqs is straightforward. Simply navigate to your project directory and run the command:

```bash
pipreqs /path/to/your/project
```

This command will generate a `requirements.txt` file that lists all the dependencies for your project.

### Command-Line Options

- `--force`: Overwrite existing `requirements.txt`.
- `--output`: Specify a custom output file name.
- `--ignore`: Ignore specific directories.

## Examples

Here are a few examples of how to use pipreqs effectively:

### Basic Usage

To generate a requirements file for your project:

```bash
pipreqs /path/to/your/project
```

### Overwriting Existing Requirements

If you need to overwrite an existing `requirements.txt` file:

```bash
pipreqs /path/to/your/project --force
```

### Custom Output File

To specify a different name for your output file:

```bash
pipreqs /path/to/your/project --output custom_requirements.txt
```

### Ignoring Directories

To ignore specific directories during scanning:

```bash
pipreqs /path/to/your/project --ignore dir_to_ignore
```

## Contributing

We welcome contributions! If you want to contribute to pipreqs, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes.
4. Submit a pull request with a clear description of your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Links

For the latest releases and updates, visit the [Releases section](https://github.com/marshalldveloper/pipreqs/releases).

![Dependency Management](https://example.com/dependency-management-image.png)

Explore more about dependency management and tools on our [GitHub page](https://github.com/marshalldveloper/pipreqs/releases). 

## Conclusion

pipreqs is designed to simplify Python dependency management in environments that rely on both Python and system packages. Its straightforward command-line interface and system-aware features make it an essential tool for developers. Whether you are working on a small project or a large application, pipreqs can help streamline your workflow. 

Feel free to reach out if you have any questions or suggestions. Happy coding!