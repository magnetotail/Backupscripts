### find date
https://stackoverflow.com/questions/18339307/find-files-in-terminal-between-a-date-range

## Datumskonvention
datestring => yyyy-MM-dd_hh:mm

## Dateiname
#### full
`f_<date>_<folder>`
#### incremental
`i_<date>_<folder>`
#### differential
`d_<date>_<folder>`

## backup location
`/var/backups/automatic/`
## log location
`/var/log/autobkp.log`

## Übergabe der Folder Parameter
an das Skript wird aus der crontab ( nur ) ein folder und ein ausgabe ordner als -o switch übergeben.

# Todos
## lesen des Backupzeitpunkts aus Dateinamen
wenn die Datei verschoben wurde ist der Modify Timestamp nicht mehr eindeutig.
