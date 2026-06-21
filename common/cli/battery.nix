{ pkgs, ... }:

let
  batteryDash = pkgs.writeShellApplication {
    name = "battery_dash";
    runtimeInputs = [
      pkgs.findutils
      pkgs.coreutils
      pkgs.gawk
    ];
    text = ''
      # Enforce strict error handling
      set -euo pipefail
      # Allow overriding the battery name via argument (e.g., battery_dash BAT1)
      BATTERY=''${1:-}
      # 1. Locate the battery directory
      if [[ -z "$BATTERY" ]]; then
          # Auto-detect the first available battery
          BAT_DIR=$(find /sys/class/power_supply/ -maxdepth 1 -name 'BAT*' | head -n 1)
          if [[ -z "$BAT_DIR" ]]; then
              echo "Error: No battery found in /sys/class/power_supply/" >&2
              exit 1
          fi
      else
          BAT_DIR="/sys/class/power_supply/$BATTERY"
          if [[ ! -d "$BAT_DIR" ]]; then
              echo "Error: Battery '$BATTERY' not found at $BAT_DIR" >&2
              exit 1
          fi
      fi
      # 2. Define the metrics we want to read
      METRICS=("status" "capacity" "charge_now" "charge_full" "current_now" "voltage_now")
      # 3. Verify all required `sysfs` files exist before attempting to read them
      for metric in "''${METRICS[@]}"; do
          if [[ ! -f "$BAT_DIR/$metric" ]]; then
              echo "Error: Required metric '$metric' is not supported by $(basename "$BAT_DIR")." >&2
              exit 1
          fi
      done
      # 4. Extract and format the data
      cd "$BAT_DIR"
      awk -v bat_name="$(basename "$BAT_DIR")" '
          {
              # Store the contents of each file in an array indexed by the filename
              a[FILENAME] = $0
          } 
          END {
              # Calculate Power (Current * Voltage) / 10^12 to get Watts
              power = (a["current_now"] * a["voltage_now"]) / 1e12
              # Print the dashboard
              printf "Battery:     %s\n", bat_name
              printf "Status:      %s\n", a["status"]
              printf "Capacity:    %s%%\n", a["capacity"]
              printf "Charge:      %s / %s µAh\n", a["charge_now"], a["charge_full"]
              printf "Power Draw:  %.2f W\n", power
          }
      ' "''${METRICS[@]}"
    '';
  };

in
{
  home.packages = [ batteryDash ];
}
