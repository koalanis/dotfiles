function cat-license
  cat ~/.config/LICENSE_TEMPLATE | read LICENSE -z

  set YEAR (date | string split " " | tail -n 1)
  printf $LICENSE $YEAR

end
