# This does not work if the game is encrypted!

def traceback_report
  backtrace = $!.backtrace.clone
  backtrace.each{ |bt|
    bt.sub!(/\{(\d+)\}/) {"[#{$1}]#{$RGSS_SCRIPTS[$1.to_i][1]}"}
  }
  return $!.message + "\n\n" + backtrace.join("\n")
end

def raise_traceback_error
  if $!.message.size >= 9000
    File.open('traceback.log', 'w') { |f| f.write($!) }
    raise 'Traceback is too big. Output in traceback.log'
  else
    raise
  end
end

def load_scripts_from_folder(path)  
  files   = []
  folders = []
  Dir.foreach(path) do |f|
    next if f == '.' || f == '..'
    (File.directory?(path + "/" + f)) ? folders.push(f) :  files.push(f)
  end
  files.sort!
  files.each do |f|
    code = File.open(path + "/" + f, "r") { |file| file.read }
    begin
      eval(code, nil, f)
    rescue ScriptError
      updateMsg = "" #"An error occured. If this error happened while launching the game, it is likely because you installed a patch on an incompatible version of the game.\nPlease note that a 5.x patch can only be applied to a 5.x full download. If you have an earlier version, you will need to redownload the full game to update.\n\n"
      raise ScriptError.new(updateMsg +$!.message)
    rescue
      $!.message.sub!($!.message, traceback_report)
      raise_traceback_error
    end
  end
  folders.sort!
  folders.each do |folder|
    load_scripts_from_folder(path + "/" + folder)
  end
end
load_scripts_from_folder("Data/Scripts")


