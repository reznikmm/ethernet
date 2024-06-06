# Ethernet
> Ethernet Namespace crate with MDIO/SMI Abstract Interface

[![Build status](https://github.com/reznikmm/ethernet/actions/workflows/alire.yml/badge.svg)](https://github.com/reznikmm/ethernet/actions/workflows/alire.yml)
[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/ethernet.json)](https://alire.ada.dev/crates/ethernet.html)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/ethernet)](https://api.reuse.software/info/github.com/reznikmm/ethernet)


## Project Purpose

The goal of this project is to provide a namespace for Ethernet packages.
We also provide an abstract interface for MDIO (Management Data Input/Output)
also known as SMI (Station Management Interface). This interface can 
be implemented on specific hardware in separate crates, facilitating hardware
abstraction and modular development.

## Overview

This project includes the following components:

1. **Ethernet** package: A root namespace for Ethernet-related functionality.
2. **Ethernet.MDIO**: An abstract interface for managing and configuring
   Ethernet PHY devices via MDIO/SMI.
3. **Ethernet.PHY_Management**: Basic high-level procedures for managing
   Ethernet PHY devices using the MDIO interface. 

## Install

Add `ethernet` as a dependency to your crate with Alire:

    alr with ethernet --use=https://github.com/reznikmm/ethernet.git

### Dependencies

The crate has no dependencies.

## Usage

This project provides a flexible framework for working with Ethernet and 
MDIO/SMI interfaces. Here are some ways you can use it:

### Creating Nested Packages in the Ethernet Namespace

You can extend the `Ethernet` namespace with your own packages to encapsulate
additional Ethernet-related functionality. This helps maintain a clean and
organized codebase.

```ada
package Ethernet.Switch is
   -- Your custom Ethernet Switch functionality here
end Ethernet.Switch;
```
### Implementing MDIO for Specific Hardware

The abstract MDIO interface can be implemented for specific hardware platforms.
By creating a concrete implementation of the MDIO_Interface, you can tailor
the MDIO operations to your hardware's requirements.

```ada
package Ethernet.STM32_MDIO is
   type STM32_MDIO_Controller is limited new Ethernet.MDIO.MDIO_Interface
     with private;

   overriding procedure Read_Register
     (Self     : in out STM32_MDIO_Controller;
      PHY      : Ethernet.MDIO.PHY_Index;
      Register : Ethernet.MDIO.Register_Index;
      Value    : out Interfaces.Unsigned_16;
      Success  : out Boolean);

   overriding procedure Write_Register
     (Self     : in out STM32_MDIO_Controller;
      PHY      : Ethernet.MDIO.PHY_Index;
      Register : Ethernet.MDIO.Register_Index;
      Value    : Interfaces.Unsigned_16;
      Success  : out Boolean);

private
   ...
end Ethernet.STM32_MDIO;
```

### Configuring Ethernet PHYs

With the `Ethernet.PHY_Management` package, you can configure PHY devices. 
This includes setting up negotiation parameters, resetting the PHY, powering
it down, retrieving its status, etc.

```ada
with Ethernet.MDIO;
with Ethernet.PHY_Management;

procedure Configure_PHY
  (MDIO : in out Ethernet.MDIO.MDIO_Interface'Class)
is
   Success : Boolean;
begin
   Ethernet.PHY_Management.Reset(MDIO, PHY => 1, Success => Success);
   -- Further configuration here
end Configure_PHY;
```

### Writing Network Drivers Managed via MDIO

You can develop network drivers that leverage the abstract MDIO interface to
manage network devices. This allows your drivers to be hardware-agnostic and
reusable across different platforms that implement the MDIO interface.

```ada
with Ethernet.MDIO;

package LAN9303_Driver is
   procedure Initialize (MDIO : in out Ethernet.MDIO.MDIO_Interface'Class);
   -- Additional driver functionality
end LAN9303_Driver;

package body LAN9303_Driver is
   procedure Initialize (MDIO : in out Ethernet.MDIO.MDIO_Interface'Class) is
      Success : Boolean;
   begin
      -- Initialize LAN9303 network device using MDIO interface
      MDIO.Write_Register
	   (PHY => 1, Register => 0, Value => 16#8000#, Success => Success);
   end Initialize;
end LAN9303_Driver;
```

## Maintainer

[@MaximReznik](https://github.com/reznikmm).

## License

[Apache-2.0 WITH LLVM-exception](LICENSES/) © Maxim Reznik
