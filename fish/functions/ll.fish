function ll --wraps=ls --wraps='eza -l' --wraps='eza -lah' --description 'alias ll eza -lah'
  eza -lah $argv
        
end
