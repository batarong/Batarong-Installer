#!/bin/bash
# Validation script to check if the ISO configuration is correct for LightDM startup

echo "Validating Batarong ISO configuration..."
echo "======================================"

# Check if required packages are listed
if grep -q "lightdm" build.sh && grep -q "lightdm-gtk-greeter" build.sh; then
    echo "✓ LightDM packages are included in build"
else
    echo "✗ Missing LightDM packages in build.sh"
fi

if grep -q "xorg-server" build.sh && grep -q "xorg-xinit" build.sh; then
    echo "✓ X.Org packages are included in build"
else
    echo "✗ Missing X.Org packages in build.sh"
fi

# Check if customize script exists and has correct permissions
if [ -f "scripts/customize_airootfs.sh" ] && [ -x "scripts/customize_airootfs.sh" ]; then
    echo "✓ customize_airootfs.sh exists and is executable"
else
    echo "✗ customize_airootfs.sh is missing or not executable"
fi

# Check if customize script contains required systemd configurations
if grep -q "systemctl enable lightdm.service" scripts/customize_airootfs.sh; then
    echo "✓ LightDM service enablement is configured"
else
    echo "✗ Missing LightDM service enablement"
fi

if grep -q "systemctl set-default graphical.target" scripts/customize_airootfs.sh; then
    echo "✓ Graphical target is set as default"
else
    echo "✗ Missing default target configuration"
fi

if grep -q "display-manager.service" scripts/customize_airootfs.sh; then
    echo "✓ Display manager service link is configured"
else
    echo "✗ Missing display manager service link"
fi

# Check if old liveenv.service is removed
if [ ! -f "scripts/liveenv.service" ]; then
    echo "✓ Old liveenv.service has been removed"
else
    echo "✗ Old liveenv.service still exists (should be removed)"
fi

# Check if build script correctly places customize script
if grep -q 'cp scripts/customize_airootfs.sh "$LIVE_DIR/customize_airootfs.sh"' build.sh; then
    echo "✓ customize_airootfs.sh is correctly placed in profile directory"
else
    echo "✗ customize_airootfs.sh placement is incorrect"
fi

echo ""
echo "Configuration validation complete!"
echo "If all checks show ✓, the ISO should boot to graphical target with LightDM."