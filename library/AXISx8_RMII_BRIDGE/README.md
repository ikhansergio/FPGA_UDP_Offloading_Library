# AXISx8_RMII_BRIDGE

AXISx8_RMII_BRIDGE - Verilog library implementing 100Base-T/10Base-T Ethernet PHY interfacing via RMII interface.

RMII_LINK_UP is an input used to indicate whether the link is up. If RMII_LINK_UP == 0, no transmission occurs. If RMII_LINK_UP == 1, data is sent to the PHY.

RMII_SPEED is an input indicating the speed at which the PHY is operating. RMII_SPEED = 0 indicates that the PHY is operating in 10Base-T mode. RMII_SPEED = 1 indicates that the PHY is operating in 100Base-T mode.

RMII_REFERENCE_CLK50 - 50MHz clock signal received from PHY.

# Under developing...
