<%
' ============================================================
' Datenbank-Konfiguration
' TODO: Verbindungsdaten eintragen, sobald bekannt.
'
' Beispiele:
'   SQL Server:
'     connString = "PROVIDER=SQLOLEDB;DATA SOURCE=servername;" & _
'                  "INITIAL CATALOG=datenbankname;USER ID=benutzer;PASSWORD=passwort;"
'
'   MS Access (.mdb, lokale Datei relativ zur Website):
'     connString = "PROVIDER=Microsoft.ACE.OLEDB.12.0;" & _
'                  "DATA SOURCE=" & Server.MapPath("/db/blog.mdb") & ";"
'
'   MySQL (ODBC-Treiber muss auf dem Server installiert sein):
'     connString = "DRIVER={MySQL ODBC 8.0 Driver};SERVER=servername;" & _
'                  "DATABASE=datenbankname;UID=benutzer;PWD=passwort;"
'
' Erwartetes Schema (bitte anpassen, falls deine Tabellen anders heißen):
'   Posts    (Id, Title, Description, PostDate, Published)
'   Tags     (Id, Name)
'   PostTags (PostId, TagId)   -- Verknüpfungstabelle
'
' Solange connString leer ist, läuft die Seite automatisch mit den
' eingebauten Beispieldaten (Fallback) weiter - kein Absturz.
' ============================================================

Dim connString
connString = ""   ' <-- hier eintragen, sobald bekannt
%>
