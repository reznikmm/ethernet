--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Interfaces;

package body Ethernet.PHY_Management is

   use type Interfaces.Unsigned_16;

   PHY_BASIC_CONTROL : constant MDIO.Register_Index := 0;
   PHY_BASIC_STATUS  : constant MDIO.Register_Index := 1;

   PHY_SPEED_SEL_MSB : constant Interfaces.Unsigned_16 := 2 ** 6;
   PHY_COL_TEST      : constant Interfaces.Unsigned_16 := 2 ** 7;
   PHY_DUPLEX        : constant Interfaces.Unsigned_16 := 2 ** 8;
   PHY_RST_AN        : constant Interfaces.Unsigned_16 := 2 ** 9;
   PHY_AN            : constant Interfaces.Unsigned_16 := 2 ** 12;
   PHY_PWR_DWN       : constant Interfaces.Unsigned_16 := 2 ** 11;
   PHY_SPEED_SEL_LSB : constant Interfaces.Unsigned_16 := 2 ** 13;
   PHY_LOOPBACK      : constant Interfaces.Unsigned_16 := 2 ** 14;

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (MDIO           : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY            : Ethernet.MDIO.PHY_Index;
      Negotiation    : Ethernet.PHY_Management.Negotiation;
      Loopback       : Boolean := False;
      Collision_Test : Boolean := False;
      Success        : out Boolean)
   is
      Value : constant Interfaces.Unsigned_16 :=
        (if Collision_Test then PHY_COL_TEST else 0) or
        (case Negotiation.Auto is
           when True =>
             (if Negotiation.Restart then PHY_RST_AN else 0) or PHY_AN,
           when False =>
             (if Negotiation.Duplex = Full then PHY_DUPLEX else 0) or
             (if Negotiation.Speed = 100 then PHY_SPEED_SEL_LSB else 0) or
             (if Negotiation.Speed = 1000 then PHY_SPEED_SEL_MSB else 0)) or
        (if Loopback then PHY_LOOPBACK else 0);
   begin
      MDIO.Write_Register (PHY, PHY_BASIC_CONTROL, Value, Success);
   end Configure;

   ----------------
   -- Get_Status --
   ----------------

   procedure Get_Status
     (MDIO    : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY     : Ethernet.MDIO.PHY_Index;
      Status  : out PHY_Status;
      Success : out Boolean)
   is
      Value : Interfaces.Unsigned_16;
   begin
      MDIO.Read_Register (PHY, PHY_BASIC_STATUS, Value, Success);

      if Success then
         Status :=
           (l00_BASE_T4               => (Value and 2**15) /= 0,
            l00_BASE_X_Full_Duplex    => (Value and 2**14) /= 0,
            l00_BASE_X_Half_Duplex    => (Value and 2**13) /= 0,
            l0_BASE_T_Full_Duplex     => (Value and 2**12) /= 0,
            l0_BASE_T_Half_Duplex     => (Value and 2**11) /= 0,
            l00_BASE_T2_Full_Duplex   => (Value and 2**10) /= 0,
            l00_BASE_T2_Half_Duplex   => (Value and 2**9) /= 0,
            Extended_Status           => (Value and 2**8) /= 0,
            MF_Preamble_Suppression   => (Value and 2**7) /= 0,
            Auto_Negotiation_Complete => (Value and 2**5) /= 0,
            Remote_Fault              => (Value and 2**4) /= 0,
            Auto_Negotiation_Ability  => (Value and 2**3) /= 0,
            Link_Up                   => (Value and 2**2) /= 0,
            Jabber_Detect             => (Value and 2**1) /= 0,
            Extended_Capability       => (Value and 2**0) /= 0);
      else
         Status := (others => False);
      end if;
   end Get_Status;

   ----------------
   -- Is_Link_Up --
   ----------------

   function Is_Link_Up
     (MDIO : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY  : Ethernet.MDIO.PHY_Index) return Boolean
   is
      Value   : Interfaces.Unsigned_16;
      Success : Boolean;
   begin
      MDIO.Read_Register (PHY, PHY_BASIC_STATUS, Value, Success);

      return Success and then (Value and 2**2) /= 0;
   end Is_Link_Up;

   ----------------
   -- Power_Down --
   ----------------

   procedure Power_Down
     (MDIO    : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY     : Ethernet.MDIO.PHY_Index;
      Success : out Boolean)
   is
      Value : Interfaces.Unsigned_16;
   begin
      MDIO.Read_Register (PHY, PHY_BASIC_CONTROL, Value, Success);

      if Success and (Value and PHY_AN) /= 0 then
         --  The PHY_AN bit of this register must be cleared before setting
         --  this PHY_PWR_DWN bit.
         Success := False;
      end if;

      if Success then
         MDIO.Write_Register
           (PHY, PHY_BASIC_CONTROL, Value or PHY_PWR_DWN, Success);
      end if;
   end Power_Down;

   -----------
   -- Reset --
   -----------

   procedure Reset
     (MDIO    : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY     : Ethernet.MDIO.PHY_Index;
      Success : out Boolean) is
   begin
      MDIO.Write_Register (PHY, PHY_BASIC_CONTROL, 16#8000#, Success);
   end Reset;

end Ethernet.PHY_Management;
