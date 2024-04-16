# bootstrap-installer

![maintained](https://img.shields.io/badge/maintained-yes-success?style=flat-square)

## Description

This project contains a "one-line" script for enabling the installation of dependencies with the dedicated avengineers repository [bootstrap](https://github.com/avengineers/bootstrap).
It is designed to simplify the process by using a Powershell script to clone the repository.
This will then be used for setting up your environment by installing different dependencies.

## How to use it

Running `install.ps1` will clone the above mentioned repository into your current working directory.
One can also utilize it by invoking a web-request (e.g. curl) to the url which is tied to the script's source.
See the following example for Powershell:

```powershell
Invoke-RestMethod https://raw.githubusercontent.com/avengineers/bootstrap-installer/v1.6.0/install.ps1 | Invoke-Expression
```

## Contributing

Contributions are welcome. Please fork this repository and create a pull request if you have something you want to add or change.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Contact Information

For any queries, please contact us via email.
