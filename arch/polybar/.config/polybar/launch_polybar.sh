if type "xrandr"; then
#  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#    MONITOR=$m polybar --reload toph &
#  done
  PORTRAIT_MONITOR=$(xrandr --query | grep " connected" | grep "1440x2560" | cut -d" " -f1) \
  polybar --reload portrait &

  LANDSCAPE_MONITOR=$(xrandr --query | grep " connected" | grep "2560x1440" | cut -d" " -f1) \
  polybar --reload landscape &
else
  polybar --reload toph &
fi
