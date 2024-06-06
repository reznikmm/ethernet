--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  Management Data Input/Output interface abstraction.
--  AKA Station management interface (SMI).

with Interfaces;

package Ethernet.MDIO is
   pragma Pure;

   type PHY_Index is mod 2 ** 5;
   --  PHY addresses (0 .. 31)
   type Register_Index is mod 2 ** 5;
   --  Register addresses (0 .. 31)

   type MDIO_Interface is limited interface;
   --  Abstract interface type for MDIO operations

   type MDIO_Interface_Access is access all
     MDIO_Interface'Class with Storage_Size => 0;

   procedure Read_Register
     (Self     : in out MDIO_Interface;
      PHY      : Ethernet.MDIO.PHY_Index;
      Register : Ethernet.MDIO.Register_Index;
      Value    : out Interfaces.Unsigned_16;
      Success  : out Boolean) is abstract;
   --  Read a register from a PHY
   --
   --  @param Self     MDIO interface instance
   --  @param PHY      Address of the PHY device
   --  @param Register Address of the register to read
   --  @param Value    Output parameter to hold the read value
   --  @param Success  Output parameter to indicate if the read was successful

   procedure Write_Register
     (Self     : in out MDIO_Interface;
      PHY      : Ethernet.MDIO.PHY_Index;
      Register : Ethernet.MDIO.Register_Index;
      Value    : Interfaces.Unsigned_16;
      Success  : out Boolean) is abstract;
   --  Write a value to a register of a PHY
   --
   --  @param Self     MDIO interface instance
   --  @param PHY      Address of the PHY device
   --  @param Register Address of the register to write
   --  @param Value    The value to write to the register
   --  @param Success  Output parameter to indicate if the write was successful

end Ethernet.MDIO;
