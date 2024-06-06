--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  PHY management high level interface
--
--  This package provides high-level procedures for managing Ethernet PHY
--  devices using the MDIO (Management Data Input/Output) interface. The
--  package includes procedures to reset the PHY, configure its negotiation
--  parameters, power down the PHY, and retrieve the PHY status. It abstracts
--  the low-level MDIO register access into higher-level operations suitable
--  for typical PHY management tasks.

with Ethernet.MDIO;

package Ethernet.PHY_Management is

   pragma Pure;

   procedure Reset
     (MDIO    : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY     : Ethernet.MDIO.PHY_Index;
      Success : out Boolean);
   --  Reset a PHY device.
   --
   --  @param MDIO    MDIO interface instance used for communication.
   --  @param PHY     Address of the PHY device to reset.
   --  @param Success Output parameter to indicate if the reset was successful.

   type Negotiation_Speed is range 10 .. 100
     with Static_Predicate => Negotiation_Speed in 10 | 100;

   type Duplex_Mode is (Half, Full);

   type Negotiation (Auto : Boolean := True) is record
      case Auto is
         when True =>
            Restart : Boolean;
         when False =>
            Speed  : Negotiation_Speed;
            Duplex : Duplex_Mode;
      end case;
   end record;

   procedure Configure
     (MDIO           : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY            : Ethernet.MDIO.PHY_Index;
      Negotiation    : Ethernet.PHY_Management.Negotiation;
      Loopback       : Boolean := False;
      Collision_Test : Boolean := False;
      Success        : out Boolean);
   --  Configure a PHY device with specified negotiation parameters.
   --
   --  @param MDIO           MDIO interface instance used for communication.
   --  @param PHY            Address of the PHY device to configure.
   --  @param Negotiation    Parameters for speed and duplex mode negotiation.
   --  @param Loopback       Enable or disable loopback mode.
   --  @param Collision_Test Enable or disable collision test mode.
   --  @param Success        Output parameter to indicate if the configuration
   --                        was successful.

   procedure Power_Down
     (MDIO    : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY     : Ethernet.MDIO.PHY_Index;
      Success : out Boolean);
   --  Power down a PHY device.
   --  To clear the power down state, call the Configure procedure.
   --
   --  @param MDIO    MDIO interface instance used for communication.
   --  @param PHY     Address of the PHY device to power down.
   --  @param Success Output parameter to indicate if the power down was
   --                 successful.

   type PHY_Status is record
      l00_BASE_T4               : Boolean;  --  100BASE-T4 able
      l00_BASE_X_Full_Duplex    : Boolean;  --  100BASE-TX with full duplex
      l00_BASE_X_Half_Duplex    : Boolean;  --  100BASE-TX with half duplex
      l0_BASE_T_Full_Duplex     : Boolean;  --  10Mbps with full duplex
      l0_BASE_T_Half_Duplex     : Boolean;  --  10Mbps with half duplex
      l00_BASE_T2_Full_Duplex   : Boolean;  --  able full duplex 100BASE-T2
      l00_BASE_T2_Half_Duplex   : Boolean;  --  able half duplex 100BASE-T2
      Auto_Negotiation_Complete : Boolean;  --  autonegotiate process completed
      Remote_Fault              : Boolean;  --  remote fault condition detected
      Auto_Negotiation_Ability  : Boolean;  --  able to perform autonegotiation
      Link_Up                   : Boolean;  --  link is up
      Jabber_Detect             : Boolean;  --  jabber condition detected
      Extended_Capability       : Boolean;  --  supports extended capabilities
   end record;

   procedure Get_Status
     (MDIO    : in out Ethernet.MDIO.MDIO_Interface'Class;
      PHY     : Ethernet.MDIO.PHY_Index;
      Status  : out PHY_Status;
      Success : out Boolean);
   --  Get the status of a PHY device.
   --
   --  @param MDIO    MDIO interface instance used for communication.
   --  @param PHY     Address of the PHY device to query.
   --  @param Status  Output parameter to hold the PHY status.
   --  @param Success Output parameter to indicate if the status retrieval was
   --                 successful.

end Ethernet.PHY_Management;
