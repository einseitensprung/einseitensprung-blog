<%@ LANGUAGE="VBScript" CODEPAGE="65001" %>
<!--#include file="config.asp"-->
<%
Response.CodePage = 65001
Response.CharSet = "utf-8"

' ------------------------------------------------------------
' Fallback-Daten: identisch zur statischen index.html, greift
' automatisch, solange keine DB verbunden ist oder eine Abfrage
' fehlschlägt. So bleibt die Seite immer funktionsfähig.
' ------------------------------------------------------------
Dim fallbackPosts
fallbackPosts = Array( _
  Array("19.08.2026", "Doconnect – neue Website", "Runderneuerung mit WCAG-AAA-Konformität und spürbar schnellerer Auslieferung.", Array("coding","wcag","performance")), _
  Array("31.07.2026", "WordPress-Sicherheitslücke sorgt für Millionen Angriffsversuche", "Eine kritische Lücke treibt gerade reihenweise Angriffe gegen WordPress-Seiten.", Array("wordpress","malware","hosting")), _
  Array("29.07.2026", "foessl.at – neue Landingpage", "Die eigene digitale Visitenkarte, von Grund auf neu gebaut.", Array("coding","design","concept")), _
  Array("22.07.2026", "einseitensprung – neue Website", "Relaunch nach über zwölf Jahren – diesmal mit KI im Workflow.", Array("ai","wcag","ui_ux")), _
  Array("17.07.2026", "Premiumchalet Karneralm", "Eine KI-generierte Website, von Hand nachgeschärft und optimiert.", Array("ai","coding")), _
  Array("21.06.2026", "KI Videoerstellung", "Synthesia im Praxistest für die eigene Videoproduktion.", Array("ai","video")), _
  Array("15.06.2026", "Are you real?", "Ein handgefertigter Cover-Editor für das Modemagazin „Style in Progress“.", Array("ui_ux","concept","coding")), _
  Array("03.05.2026", "doconnect – Flyer & Visitenkarten", "Printmaterial für das Gesundheitsprojekt doconnect.", Array("health","design")), _
  Array("15.04.2026", "doconnect – digitale Entlastung für Ihre Ordination", "Ein neuer, barrierefreier Service für Ärztinnen und Ärzte.", Array("health","wcag","coding")), _
  Array("28.03.2026", "POWER!!!BANK – UGREEN Nexode", "Praxistest: die Powerbank fürs mobile Workspace-Setup.", Array("hardware","workspace")) _
)

Dim fallbackTags
fallbackTags = Array( _
  Array("AI",14), Array("backup",1), Array("betrug",1), Array("cad",1), Array("coding",28), _
  Array("concept",12), Array("cookies",1), Array("design",14), Array("hardware",11), Array("health",5), _
  Array("hosting",3), Array("linux",1), Array("malware",3), Array("newsletter",1), Array("performance",7), _
  Array("phishing",1), Array("promotion",5), Array("seo",11), Array("setup",4), Array("smarthome",1), _
  Array("smishing",1), Array("software",3), Array("storage",1), Array("testing",2), Array("ui_ux",8), _
  Array("video",7), Array("virtualisierung",2), Array("wcag",14), Array("woocommerce",1), Array("wordpress",7), _
  Array("workspace",7) _
)

' ------------------------------------------------------------
' Hilfsfunktionen: Tag-Kategorie (Farbe) und Tag-Gewichtung (Größe)
' ------------------------------------------------------------
Function TagBucketKey(tagName)
  Dim t : t = LCase(tagName)
  Select Case t
    Case "coding","wordpress","hosting","hardware","software","linux","virtualisierung","storage","backup","cad","setup","workspace","woocommerce","smarthome"
      TagBucketKey = "blue"
    Case "design","ui_ux","concept","promotion","newsletter"
      TagBucketKey = "magenta"
    Case "performance","seo","testing"
      TagBucketKey = "lime"
    Case "wcag","health","cookies"
      TagBucketKey = "cyan"
    Case Else
      TagBucketKey = "plum"
  End Select
End Function

Function TagTier(cnt)
  If cnt >= 20 Then
    TagTier = "t1"
  ElseIf cnt >= 10 Then
    TagTier = "t2"
  ElseIf cnt >= 5 Then
    TagTier = "t3"
  ElseIf cnt >= 2 Then
    TagTier = "t4"
  Else
    TagTier = "t5"
  End If
End Function

Function GetPostTags(conn, postId)
  Dim rsT, sql, arr(), n
  n = -1
  ReDim arr(50)
  sql = "SELECT T.Name FROM Tags T INNER JOIN PostTags PT ON T.Id = PT.TagId WHERE PT.PostId = " & CLng(postId)
  Set rsT = Server.CreateObject("ADODB.Recordset")
  On Error Resume Next
  rsT.Open sql, conn, 3, 1
  If Err.Number = 0 Then
    Do While Not rsT.EOF And n < 50
      n = n + 1
      arr(n) = rsT.Fields("Name").Value
      rsT.MoveNext
    Loop
    rsT.Close
  End If
  Err.Clear
  On Error Goto 0
  Set rsT = Nothing
  If n >= 0 Then
    ReDim Preserve arr(n)
  Else
    arr = Array()
  End If
  GetPostTags = arr
End Function

' ------------------------------------------------------------
' Datenbankverbindung (mit automatischem Fallback bei Fehlern)
' ------------------------------------------------------------
Dim conn, dbAvailable
dbAvailable = False

If Trim(connString) <> "" Then
  Set conn = Server.CreateObject("ADODB.Connection")
  On Error Resume Next
  conn.Open connString
  If Err.Number = 0 Then
    dbAvailable = True
  Else
    Err.Clear
  End If
  On Error Goto 0
End If

' ---- Posts laden ----
Dim posts, postCount, rsPosts
postCount = -1

If dbAvailable Then
  Set rsPosts = Server.CreateObject("ADODB.Recordset")
  On Error Resume Next
  rsPosts.Open "SELECT TOP 10 Id, Title, Description, PostDate FROM Posts WHERE Published = 1 ORDER BY PostDate DESC", conn, 3, 1
  If Err.Number = 0 Then
    ReDim posts(9)
    Do While Not rsPosts.EOF And postCount < 9
      postCount = postCount + 1
      Dim d, dateStr
      d = rsPosts.Fields("PostDate").Value
      dateStr = Right("0" & Day(d), 2) & "." & Right("0" & Month(d), 2) & "." & Year(d)
      posts(postCount) = Array(dateStr, rsPosts.Fields("Title").Value, rsPosts.Fields("Description").Value, GetPostTags(conn, rsPosts.Fields("Id").Value))
      rsPosts.MoveNext
    Loop
    rsPosts.Close
    If postCount >= 0 Then ReDim Preserve posts(postCount)
  End If
  Err.Clear
  On Error Goto 0
  Set rsPosts = Nothing
End If

If postCount < 0 Then
  posts = fallbackPosts
End If

' ---- Tag-Cloud laden ----
Dim tagsCloud, tcCount, rsTags
tcCount = -1

If dbAvailable Then
  Set rsTags = Server.CreateObject("ADODB.Recordset")
  On Error Resume Next
  rsTags.Open "SELECT T.Name AS Name, COUNT(*) AS Cnt FROM Tags T INNER JOIN PostTags PT ON T.Id = PT.TagId GROUP BY T.Name ORDER BY T.Name", conn, 3, 1
  If Err.Number = 0 Then
    ReDim tagsCloud(200)
    Do While Not rsTags.EOF And tcCount < 200
      tcCount = tcCount + 1
      tagsCloud(tcCount) = Array(rsTags.Fields("Name").Value, CLng(rsTags.Fields("Cnt").Value))
      rsTags.MoveNext
    Loop
    rsTags.Close
    If tcCount >= 0 Then ReDim Preserve tagsCloud(tcCount)
  End If
  Err.Clear
  On Error Goto 0
  Set rsTags = Nothing
End If

If tcCount < 0 Then
  tagsCloud = fallbackTags
End If

If dbAvailable Then
  conn.Close
End If
Set conn = Nothing
%>
<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Einseitensprung Journal</title>
<meta name="description" content="Ein handgebauter Onepager im Look von einseitensprung.at/blog — Journal-Feed, Verifiziert-Siegel und Kontakt.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Josefin+Sans:wght@300;500;600;700&family=Inconsolata:wght@400;500;700&display=swap" rel="stylesheet">

<style>
  :root{
    --paper:#faf5f1;
    --paper-raised:#f2e8e2;
    --ink:#22111a;
    --ink-soft:#6a5460;
    --rule: rgba(34,17,26,0.15);
    --plum:#8e1963;
    --magenta:#bc2184;
    --blue:#3f6fc4;
    --lime:#5c7a2e;
    --cyan:#1c8686;
  }

  @media (prefers-color-scheme: dark){
    :root:not([data-theme="light"]){
      --paper:#170e14;
      --paper-raised:#241621;
      --ink:#f5ece8;
      --ink-soft:#c7aec0;
      --rule: rgba(245,236,232,0.18);
      --plum:#e35aa8;
      --magenta:#ff7fc4;
      --blue:#86a8ee;
      --lime:#a3c46e;
      --cyan:#5fd6d6;
    }
  }

  :root[data-theme="dark"]{
    --paper:#170e14;
    --paper-raised:#241621;
    --ink:#f5ece8;
    --ink-soft:#c7aec0;
    --rule: rgba(245,236,232,0.18);
    --plum:#e35aa8;
    --magenta:#ff7fc4;
    --blue:#86a8ee;
    --lime:#a3c46e;
    --cyan:#5fd6d6;
  }

  *{ box-sizing:border-box; }

  body{
    margin:0;
    background:var(--paper);
    color:var(--ink);
    font-family:'Inconsolata', ui-monospace, 'SFMono-Regular', Menlo, monospace;
    font-size:16px;
    line-height:1.6;
    -webkit-font-smoothing:antialiased;
  }

  a{ color:var(--plum); }
  a:focus-visible, button:focus-visible, .rail-item:focus-visible{
    outline:2px solid var(--magenta);
    outline-offset:3px;
    border-radius:2px;
  }

  h1,h2,h3,.display{
    font-family:'Josefin Sans', 'Century Gothic', Futura, sans-serif;
    font-weight:600;
    text-wrap:balance;
    margin:0;
  }

  .wrap{
    max-width:760px;
    margin:0 auto;
    padding:0 24px;
  }

  /* ---------- Hero ---------- */

  .hero{
    padding:72px 0 48px;
    border-bottom:1px solid var(--rule);
  }

  .wordmark{
    font-size:clamp(2.4rem, 7vw, 4.2rem);
    font-weight:700;
    letter-spacing:-0.01em;
    color:var(--ink);
  }
  .wordmark .dot{ color:var(--magenta); }

  .hero-body{
    display:flex;
    flex-wrap:wrap;
    gap:36px;
    margin-top:22px;
    align-items:flex-start;
  }

  .intro{ flex:1 1 260px; min-width:220px; }

  .tagline{
    margin-top:0;
    max-width:34ch;
    color:var(--ink-soft);
    font-size:1.02rem;
  }

  .tagcloud{
    flex:1 1 300px;
    min-width:240px;
    display:flex;
    flex-wrap:wrap;
    align-content:flex-start;
    gap:7px 9px;
    padding-top:2px;
  }
  .cloud-tag{
    --tag-c:var(--plum);
    text-decoration:none;
    color:var(--ink);
    border:1px solid var(--rule);
    border-radius:999px;
    padding:3px 10px;
    line-height:1.4;
    white-space:nowrap;
  }
  .cloud-tag:hover, .cloud-tag:focus-visible{
    border-color:var(--tag-c);
    color:var(--tag-c);
    background:var(--paper-raised);
  }
  .cloud-tag.t1{ font-size:1.05rem; font-weight:700; }
  .cloud-tag.t2{ font-size:0.94rem; font-weight:600; }
  .cloud-tag.t3{ font-size:0.85rem; font-weight:500; }
  .cloud-tag.t4{ font-size:0.76rem; font-weight:400; }
  .cloud-tag.t5{ font-size:0.7rem; font-weight:400; opacity:.72; }
  .cloud-tag.c-blue{ --tag-c:var(--blue); }
  .cloud-tag.c-magenta{ --tag-c:var(--magenta); }
  .cloud-tag.c-lime{ --tag-c:var(--lime); }
  .cloud-tag.c-cyan{ --tag-c:var(--cyan); }
  .cloud-tag.c-plum{ --tag-c:var(--plum); }

  .prompt{
    margin-top:20px;
    display:inline-flex;
    align-items:baseline;
    gap:10px;
    font-size:0.95rem;
    color:var(--ink);
    background:var(--paper-raised);
    border:1px solid var(--rule);
    border-radius:6px;
    padding:10px 14px;
  }
  .prompt .sym{ color:var(--plum); font-weight:700; }
  .cursor{
    display:inline-block;
    width:8px; height:1.1em;
    background:var(--magenta);
    margin-left:2px;
    animation:blink 1.1s steps(1) infinite;
    vertical-align:text-bottom;
  }
  @media (prefers-reduced-motion: reduce){ .cursor{ animation:none; opacity:.75; } }
  @keyframes blink{ 50%{ opacity:0; } }

  /* ---------- Section labels ---------- */

  .label{
    font-size:0.8rem;
    letter-spacing:0.14em;
    text-transform:uppercase;
    color:var(--ink-soft);
    margin:0 0 22px;
  }
  .label::before{ content:"// "; color:var(--magenta); }

  section{ padding:56px 0; border-bottom:1px solid var(--rule); }
  section:last-of-type{ border-bottom:none; }

  /* ---------- Journal / log feed ---------- */

  .rail{
    display:grid;
    grid-template-columns:96px 1fr;
    column-gap:18px;
  }

  .rail-item{
    display:contents;
  }

  .rail-date{
    grid-column:1;
    position:relative;
    font-size:0.82rem;
    color:var(--ink-soft);
    padding-top:2px;
    text-align:right;
    font-variant-numeric:tabular-nums;
  }

  .rail-date::after{
    content:"";
    position:absolute;
    top:6px;
    right:-19px;
    width:9px; height:9px;
    border-radius:50%;
    background:var(--dot, var(--plum));
    box-shadow:0 0 0 3px var(--paper);
  }

  .rail-line{
    grid-column:1;
    position:relative;
  }
  .rail-line::before{
    content:"";
    position:absolute;
    top:0; bottom:0;
    right:-15px;
    width:1px;
    background:var(--rule);
  }

  .entry{
    grid-column:2;
    padding-bottom:34px;
  }
  .rail-item:last-child .entry{ padding-bottom:6px; }

  .entry h3{
    font-size:1.28rem;
    margin-bottom:6px;
    color:var(--ink);
  }

  .entry p{
    margin:0 0 12px;
    color:var(--ink-soft);
    font-size:0.96rem;
    max-width:52ch;
  }

  .tags{ display:flex; flex-wrap:wrap; gap:8px; }
  .tag{
    display:inline-flex;
    align-items:center;
    gap:6px;
    font-size:0.76rem;
    letter-spacing:0.03em;
    padding:3px 9px 3px 7px;
    border:1px solid var(--rule);
    border-radius:999px;
    color:var(--ink);
  }
  .tag::before{
    content:"";
    width:7px; height:7px;
    border-radius:50%;
    background:var(--c, var(--plum));
  }

  /* ---------- About ---------- */

  .about{
    display:grid;
    grid-template-columns:1fr;
    gap:18px;
  }
  .about .who{
    font-family:'Josefin Sans', sans-serif;
    font-size:1.6rem;
    font-weight:600;
  }
  .about .role{ color:var(--plum); }
  .focus-list{
    display:flex;
    flex-wrap:wrap;
    gap:10px 22px;
    margin-top:6px;
    padding:0;
    list-style:none;
    color:var(--ink-soft);
    font-size:0.92rem;
  }
  .focus-list li::before{ content:"— "; color:var(--magenta); }

  /* ---------- Verified / seals ---------- */

  .seals{
    display:flex;
    flex-wrap:wrap;
    gap:14px;
  }
  .seal{
    border:1px solid var(--rule);
    border-radius:10px;
    padding:14px 16px;
    min-width:150px;
    background:var(--paper-raised);
  }
  .seal .big{
    font-family:'Josefin Sans', sans-serif;
    font-weight:700;
    font-size:1.05rem;
    color:var(--plum);
  }
  .seal .small{
    display:block;
    margin-top:4px;
    font-size:0.76rem;
    color:var(--ink-soft);
    letter-spacing:0.02em;
  }

  /* ---------- Footer ---------- */

  footer{ padding:48px 0 72px; }
  .connect-line{
    display:flex;
    align-items:baseline;
    justify-content:space-between;
    flex-wrap:wrap;
    gap:16px;
    margin-bottom:26px;
  }
  .connect-line .site{
    font-family:'Josefin Sans', sans-serif;
    font-weight:600;
    font-size:1.1rem;
  }
  .connect-line .site .dot{ color:var(--magenta); }
  .connect-line .meta{ color:var(--ink-soft); font-size:0.86rem; }

  .socials{
    display:flex;
    flex-wrap:wrap;
    gap:10px;
  }
  .socials a{
    text-decoration:none;
    font-size:0.82rem;
    color:var(--ink);
    border:1px solid var(--rule);
    border-radius:6px;
    padding:7px 11px;
    transition:border-color .15s, color .15s;
  }
  .socials a:hover{ border-color:var(--magenta); color:var(--magenta); }

  .fineprint{
    margin-top:30px;
    font-size:0.78rem;
    color:var(--ink-soft);
    border-top:1px solid var(--rule);
    padding-top:20px;
  }

  @media (max-width:520px){
    .rail{ grid-template-columns:64px 1fr; }
    .rail-date::after{ right:-14px; }
    .rail-line::before{ right:-11px; }
  }
</style>
</head>
<body>
<!-- Datenquelle: <% If dbAvailable Then Response.Write "Datenbank" Else Response.Write "Fallback (keine DB verbunden)" End If %> -->

<div class="wrap">

  <header class="hero">
    <div class="wordmark">einseitensprung<span class="dot">.</span>at</div>
    <div class="hero-body">
      <div class="intro">
        <p class="tagline">Ein Blog rund um den einseitensprung.at&nbsp;Orbit &amp; mehr &mdash; Code, Design, Barrierefreiheit, KI.</p>
        <div class="prompt">
          <span class="sym">$</span> lesen --thema=alles<span class="cursor" aria-hidden="true"></span>
        </div>
      </div>
      <nav class="tagcloud" aria-label="Themen">
<%
Dim ti, tName, tCount
For ti = 0 To UBound(tagsCloud)
  tName = tagsCloud(ti)(0)
  tCount = tagsCloud(ti)(1)
%>        <a class="cloud-tag <%= TagTier(tCount) %> c-<%= TagBucketKey(tName) %>" href="https://einseitensprung.at/blog/search.asp?tag=<%= Server.URLEncode(tName) %>" target="_blank" rel="noopener">#<%= Server.HTMLEncode(tName) %></a>
<%
Next
%>      </nav>
    </div>
  </header>

  <section aria-labelledby="journal-label">
    <p class="label" id="journal-label">journal</p>

    <div class="rail">
<%
Dim pi, p, tags, tj, dotKey
For pi = 0 To UBound(posts)
  p = posts(pi)
  tags = p(3)
  If UBound(tags) >= 0 Then
    dotKey = TagBucketKey(tags(0))
  Else
    dotKey = "plum"
  End If
%>
      <div class="rail-item" style="--dot:var(--<%= dotKey %>)">
        <div class="rail-date"><%= p(0) %></div>
        <div class="rail-line"></div>
        <div class="entry">
          <h3><%= Server.HTMLEncode(p(1)) %></h3>
          <p><%= Server.HTMLEncode(p(2)) %></p>
          <div class="tags">
<%
  For tj = 0 To UBound(tags)
%>            <span class="tag" style="--c:var(--<%= TagBucketKey(tags(tj)) %>)"><%= Server.HTMLEncode(tags(tj)) %></span>
<%
  Next
%>          </div>
        </div>
      </div>
<%
Next
%>
    </div>
  </section>

  <section aria-labelledby="whoami-label">
    <p class="label" id="whoami-label">whoami</p>
    <div class="about">
      <div class="who">Stephan Fössl <span class="role">— Web &amp; UI/UX Design</span></div>
      <ul class="focus-list">
        <li>Webentwicklung &amp; Coding</li>
        <li>Barrierefreiheit (WCAG)</li>
        <li>KI-Integration</li>
        <li>Sicherheit</li>
        <li>Performance-Optimierung</li>
      </ul>
    </div>
  </section>

  <section aria-labelledby="verified-label">
    <p class="label" id="verified-label">verifiziert</p>
    <div class="seals">
      <div class="seal"><span class="big">100%</span><span class="small">HTML5 &amp; CSS3 valide</span></div>
      <div class="seal"><span class="big">AAA</span><span class="small">WCAG AAA &amp; EN&nbsp;301&nbsp;549</span></div>
      <div class="seal"><span class="big">100%</span><span class="small">DSGVO&#8209;konform</span></div>
      <div class="seal"><span class="big">0</span><span class="small">Cookies gesetzt</span></div>
      <div class="seal"><span class="big">1:1</span><span class="small">handgefertigt</span></div>
    </div>
  </section>

  <footer>
    <div class="connect-line">
      <span class="site">einseitensprung<span class="dot">.</span>at</span>
      <span class="meta">Wien, Österreich</span>
    </div>
    <nav class="socials" aria-label="Social Media">
      <a href="https://einseitensprung.at/blog/" rel="noopener">Blog</a>
      <a href="#" rel="noopener">Facebook</a>
      <a href="#" rel="noopener">LinkedIn</a>
      <a href="#" rel="noopener">Instagram</a>
      <a href="#" rel="noopener">Mastodon</a>
      <a href="#" rel="noopener">Bluesky</a>
      <a href="#" rel="noopener">Pixelfed</a>
    </nav>
    <p class="fineprint">Diese Seite ist ein inoffizieller, handgebauter Onepager basierend auf einseitensprung.at/blog &mdash; für den vollständigen Blog inklusive Newsletter geht’s zum Original.</p>
  </footer>

</div>
</body>
</html>
