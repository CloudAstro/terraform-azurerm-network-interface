# Azure Network Interface Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/CloudAstro/network-interface/azurerm/)


This module manages the creation and configuration of Network Interfaces in Microsoft Azure. It allows you to define various settings such as IP configurations, DNS servers, and network security groups.

## Features

- **Network Interface Creation**: Provision and configure Azure Network Interfaces with various settings.
- **IP Configuration**: Manage both private and public IP addresses with flexible allocation methods.
- **DNS Management**: Customize DNS servers for the Network Interface, overriding the default settings of the Virtual Network if needed.
- **Network Security**: Attach Network Security Groups (NSGs) and Application Security Groups (ASGs) to manage traffic flow.
- **Accelerated Networking**: Enable or disable accelerated networking to enhance performance for supported VM sizes.

## Example Usage

This example demonstrates how to deploy a Network Interface with custom IP configurations and optionally associate it with a Network Security Group, Public IP, or Application Security Group.
