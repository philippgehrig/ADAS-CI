#!/bin/bash

# Display a dialog menu for selecting the Jetson configuration
CHOICE=$(dialog --title "Jetson Flash Selection" --menu "Choose a configuration file:" 15 60 4 \
    "1" "Jetson AGX Orin" \
    "2" "Jetson Orin Nano" \
    "3" "Jetson AGX Xavier" \
    2>&1 >/dev/tty)

# Check if a valid choice was made
if [ -z "$CHOICE" ]; then
    echo "No configuration selected. Stopping program."
    exit 1
fi

# Map the selection to the corresponding configuration file
case $CHOICE in
    1)
        CONFIG="jetson-agx-orin-devkit.conf"
        ;;
    2)
        CONFIG="jetson-orin-nano-devkit.conf"
        ;;
    3)
        CONFIG="jetson-agx-xavier-devkit.conf"
        ;;
    *)
        echo "Unknown choice. Stopping program."
        exit 1
        ;;
esac

# Display a dialog menu for selecting the PCIe mode
PCIe_CHOICE=$(dialog --title "PCIe Configuration" --menu "Choose PCIe mode:" 10 40 2 \
    "1" "Host" \
    "2" "Endpoint" \
    2>&1 >/dev/tty)

# Check if a valid choice was made
if [ -z "$PCIe_CHOICE" ]; then
    echo "No PCIe configuration selected. Stopping program."
    exit 1
fi

# Define actions based on the PCIe mode selection
case $PCIe_CHOICE in
    1) # Host mode
        PCIe_MODE="Host"
        echo "Configuring $CONFIG for PCIe Host mode..."
        
        # Perform host mode actions for each board
        case $CHOICE in
            1) # Jetson AGX Orin in Host mode
                echo "Removing ODMDATA for Jetson AGX Orin..."
                sed -i '/^ODMDATA/d' $CONFIG
                ;;
            2) # Jetson Orin Nano in Host mode
                echo "Removing ODMDATA for Jetson Orin Nano..."
                sed -i '/^ODMDATA/d' $CONFIG
                ;;
            3) # Jetson AGX Xavier in Host mode
                echo "Removing ODMDATA for Jetson AGX Xavier..."
                sed -i '/^ODMDATA/d' $CONFIG
                ;;
            *)
                echo "Unknown board for Host mode. Stopping program."
                exit 1
                ;;
        esac
        ;;
        
    2) # Endpoint mode
        PCIe_MODE="Endpoint"
        echo "Configuring $CONFIG for PCIe Endpoint mode..."
        
        # Perform endpoint mode actions for each board
        case $CHOICE in
            1) # Jetson AGX Orin in Endpoint mode
                echo "Setting ODMDATA for Jetson AGX Orin..."
                if grep -q '^ODMDATA' $CONFIG; then
                    # Remove any existing ODMDATA and add it to the top of the file
                    sed -i '/^ODMDATA/d' $CONFIG
                    sed -i "1s/^/ODMDATA=\"gbe-uphy-config-22,nvhs-uphy-config-1,hsio-uphy-config-0,gbe0-enable-10g,hsstp-lane-map-3\"\n/" $CONFIG
                else
                    echo 'ODMDATA="gbe-uphy-config-22,nvhs-uphy-config-1,hsio-uphy-config-0,gbe0-enable-10g,hsstp-lane-map-3"' | cat - $CONFIG > temp && mv temp $CONFIG
                fi
                ;;
            2) # Jetson Orin Nano in Endpoint mode
                echo "Setting ODMDATA for Jetson Orin Nano..."
                if grep -q '^ODMDATA' $CONFIG; then
                    # Remove any existing ODMDATA and add it to the top of the file
                    sed -i '/^ODMDATA/d' $CONFIG
                    sed -i "1s/^/ODMDATA=\"gbe-uphy-config-8,hsstp-lane-map-3,hsio-uphy-config-41\"\n/" $CONFIG
                else
                    echo 'ODMDATA="gbe-uphy-config-8,hsstp-lane-map-3,hsio-uphy-config-41"' | cat - $CONFIG > temp && mv temp $CONFIG
                fi
                ;;
            3) # Jetson AGX Xavier in Endpoint mode
                echo "Setting ODMDATA for Jetson AGX Xavier..."
                if grep -q '^ODMDATA' $CONFIG; then
                    # Remove any existing ODMDATA and add it to the top of the file
                    sed -i '/^ODMDATA/d' $CONFIG
                    sed -i "1s/^/ODMDATA=\"0x09191000\"\n/" $CONFIG
                else
                    echo 'ODMDATA="0x09191000"' | cat - $CONFIG > temp && mv temp $CONFIG
                fi
                ;;
            *)
                echo "Unknown board for Endpoint mode. Stopping program."
                exit 1
                ;;
        esac
        ;;
        
    *)
        echo "Unknown PCIe choice. Stopping program."
        exit 1
        ;;
esac

# Display a success message
dialog --msgbox "Configuration updated for $CONFIG in PCIe $PCIe_MODE mode!" 6 50

clear
echo "Configuration complete: Updated $CONFIG for PCIe $PCIe_MODE mode."

# End the script
exit 0
