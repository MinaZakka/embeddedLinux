 #!/usr/bin/bash-x
   if [ $# -lt 1 ]
   then
       echo "Please enter at least one directory to backup it"
   else
       if [ ! -d backups ]; then mkdir backups; fi
       Date=$(date +%d-%m-%y)
       for dir in "$@"
      do
          dirName="backup_"$dir"_"$Date".tar.gz"
          tar czf ./backups/$dirName $dir
          if [ $? -eq 0 ];then
              echo $dirName" is created successfully."
          else
              echo "tar command failed to create"$dirName"."
          fi
      done
  fi
