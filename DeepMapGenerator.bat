@echo off
chcp 65001 >nul 2>&1
set "DMGBAT=%~f0"
set "DMGTMP=%TEMP%\dmgen%RANDOM%.ps1"
echo Extracting script...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$lines=[IO.File]::ReadAllLines($env:DMGBAT,[System.Text.Encoding]::UTF8);$start=0;for($j=0;$j-lt$lines.Length;$j++){if($lines[$j] -eq 'REM ###PSSTART###'){$start=$j+1;break}};[IO.File]::WriteAllLines($env:DMGTMP,$lines[$start..($lines.Length-1)],[System.Text.Encoding]::UTF8)"
if not exist "%DMGTMP%" (
    echo [ERROR] Extract failed!
    pause
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%DMGTMP%"
del "%DMGTMP%" 2>nul
exit /b
REM ###PSSTART###
Add-Type -AssemblyName System.Web
Add-Type -AssemblyName System.Windows.Forms

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  無限層級導航地圖生成器 v3.1 (HTML)" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "請選擇要掃描的資料夾"
$dialog.ShowNewFolderButton = $false

if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "[取消] 未選擇資料夾" -ForegroundColor Yellow
    $null = Read-Host "Press Enter to exit"
    exit
}

$TargetPath = $dialog.SelectedPath
$OutputFile = Join-Path ([Environment]::GetFolderPath("Desktop")) "導航地圖.html"

Write-Host "[掃描目標] $TargetPath" -ForegroundColor Green
Write-Host "[輸出位置] $OutputFile" -ForegroundColor Green
Write-Host ""
Write-Host "[進行中] 正在深層掃描..." -ForegroundColor Yellow

function HE([string]$s) { return [System.Web.HttpUtility]::HtmlEncode($s) }

function Get-Info([string]$ext) {
    switch ($ext.ToLower()) {
        '.exe'  { return @('file-exe', 'EXE', 'exe') }
        '.msi'  { return @('file-exe', 'MSI', 'exe') }
        '.xlsx' { return @('file-xlsx','XLS','xlsx') }
        '.xls'  { return @('file-xlsx','XLS','xlsx') }
        '.csv'  { return @('file-xlsx','CSV','xlsx') }
        '.pdf'  { return @('file-pdf', 'PDF','pdf') }
        '.docx' { return @('file-docx','DOC','docx') }
        '.doc'  { return @('file-docx','DOC','docx') }
        '.pptx' { return @('file-pptx','PPT','pptx') }
        '.ppt'  { return @('file-pptx','PPT','pptx') }
        '.txt'  { return @('file-txt', 'TXT','txt') }
        '.log'  { return @('file-txt', 'LOG','txt') }
        '.ini'  { return @('file-txt', 'INI','txt') }
        '.bat'  { return @('file-txt', 'BAT','txt') }
        '.cmd'  { return @('file-txt', 'CMD','txt') }
        '.ps1'  { return @('file-txt', 'PS1','txt') }
        '.jpg'  { return @('file-img', 'JPG','img') }
        '.jpeg' { return @('file-img', 'JPG','img') }
        '.png'  { return @('file-img', 'PNG','img') }
        '.gif'  { return @('file-img', 'GIF','img') }
        '.bmp'  { return @('file-img', 'BMP','img') }
        '.svg'  { return @('file-img', 'SVG','img') }
        '.mp4'  { return @('file-vid', 'MP4','img') }
        '.avi'  { return @('file-vid', 'AVI','img') }
        '.mkv'  { return @('file-vid', 'MKV','img') }
        '.mp3'  { return @('file-aud', 'MP3','img') }
        '.wav'  { return @('file-aud', 'WAV','img') }
        '.zip'  { return @('file-other','ZIP','other') }
        '.rar'  { return @('file-other','RAR','other') }
        '.7z'   { return @('file-other','7Z', 'other') }
        default { return @('file-other','FILE','other') }
    }
}

$global:folderCount = 0
$global:fileCount   = 0

function Scan([string]$path, [int]$depth) {
    $sb = [System.Text.StringBuilder]::new()
    try {
        $dirs  = @(Get-ChildItem -LiteralPath $path -Directory -ErrorAction SilentlyContinue)
        $files = @(Get-ChildItem -LiteralPath $path -File      -ErrorAction SilentlyContinue)
    } catch { return "" }

    $openAttr = if ($depth -le 1) { " open" } else { "" }
    [void]$sb.Append("<ul>")

    foreach ($d in $dirs) {
        $global:folderCount++
        $dn   = HE $d.Name
        $dpHE = HE $d.FullName
        $dpURL = $d.FullName.Replace('\','/')
        $sc = 0; $fc = 0
        try {
            $sc = @(Get-ChildItem -LiteralPath $d.FullName -Directory -EA SilentlyContinue).Count
            $fc = @(Get-ChildItem -LiteralPath $d.FullName -File      -EA SilentlyContinue).Count
        } catch {}

        [void]$sb.Append("<li><details$openAttr><summary>")
        [void]$sb.Append("<span class='fi'>[DIR]</span>")
        [void]$sb.Append("<span class='fn'>$dn <span class='ct'>$sc 夾 $fc 檔</span></span>")
        [void]$sb.Append("<a class='ab of' href='file:///$dpURL/' target='_blank'>開啟資料夾</a>")
        [void]$sb.Append("<button class='ab sb' data-path=`"$dpHE`" data-name=`"$dn`" data-type=`"folder`" onclick=`"toggleFav(this)`">☆</button>")
        [void]$sb.Append("</summary>")
        [void]$sb.Append((Scan $d.FullName ($depth + 1)))
        [void]$sb.Append("</details></li>")

        if ($global:folderCount % 50 -eq 0) {
            Write-Host "  已掃描 $($global:folderCount) 個資料夾..." -ForegroundColor DarkGray
        }
    }

    foreach ($f in $files) {
        $global:fileCount++
        $fn    = HE $f.Name
        $fpHE  = HE $f.FullName
        $fpURL = $f.FullName.Replace('\','/')
        $info  = Get-Info $f.Extension

        [void]$sb.Append("<li data-type='$($info[2])'>")
        [void]$sb.Append("<a class='fi2 $($info[0])' href='file:///$fpURL' target='_blank'>[$($info[1])] $fn</a>")
        [void]$sb.Append("<button class='fs' data-path=`"$fpHE`" data-name=`"$fn`" data-type=`"file`" onclick=`"toggleFav(this)`">☆</button>")
        [void]$sb.Append("</li>")
    }

    [void]$sb.Append("</ul>")
    return $sb.ToString()
}

$treeHtml = Scan $TargetPath 0

Write-Host ""
Write-Host "[統計] $($global:folderCount) 個資料夾, $($global:fileCount) 個檔案" -ForegroundColor Cyan
Write-Host "[組裝] 正在生成 HTML..." -ForegroundColor Yellow

$rootEnc = HE $TargetPath
$fcnt    = $global:folderCount
$filecnt = $global:fileCount

$fullHtml = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>導航地圖</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Microsoft JhengHei','Segoe UI',sans-serif;background:#0d1117;color:#c9d1d9}
button{font-family:inherit;cursor:pointer}
#fav-btn{position:fixed;top:12px;right:12px;z-index:999;background:#d29922;color:#fff;border:none;padding:8px 16px;border-radius:8px;font-size:14px;font-weight:bold;box-shadow:0 2px 10px rgba(0,0,0,.5)}
#fav-btn:hover{background:#e6ac00}
#sidebar{position:fixed;top:0;right:-330px;width:320px;height:100%;background:#161b22;border-left:1px solid #30363d;z-index:998;overflow-y:auto;padding:18px;padding-top:55px;transition:right .3s}
#sidebar.open{right:0}
#sidebar h3{color:#d29922;font-size:14px;margin-bottom:10px;padding-bottom:6px;border-bottom:1px solid #30363d}
.fv{display:flex;align-items:center;gap:6px;padding:5px 8px;margin:3px 0;background:#21262d;border-radius:5px;font-size:12px}
.fv .fvn{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:#c9d1d9}
.fv .fvop{color:#58a6ff;font-size:11px;border:1px solid #58a6ff;padding:1px 6px;border-radius:3px;background:transparent}
.fv .fvop:hover{background:#58a6ff;color:#fff}
.fv .fvx{color:#f85149;font-size:15px;padding:0 3px;background:transparent;border:none}
.sep{border:0;border-top:1px solid #30363d;margin:12px 0}
.flbl{font-size:12px;color:#888;display:flex;align-items:center;gap:5px;margin:3px 0;cursor:pointer}
#main{padding:25px 30px;max-width:1400px}
.rt{font-size:18px;color:#58a6ff;border-bottom:2px solid #58a6ff;padding-bottom:10px;margin-bottom:15px;word-break:break-all}
.tb{display:flex;gap:8px;margin-bottom:12px;flex-wrap:wrap;align-items:center}
.tb input{flex:1;min-width:180px;padding:7px 12px;background:#21262d;border:1px solid #30363d;border-radius:6px;color:#c9d1d9;font-size:13px;outline:none}
.tb input:focus{border-color:#58a6ff}
.tb button{padding:6px 14px;border:none;border-radius:6px;font-size:12px;font-weight:bold}
.be{background:#238636;color:#fff}.be:hover{background:#2ea043}
.bc{background:#da3633;color:#fff}.bc:hover{background:#f85149}
.stats{color:#555;font-size:12px;margin-bottom:12px}
ul{list-style:none;padding-left:20px;border-left:1px dashed #30363d}
li{margin:2px 0;position:relative}
li::before{content:"";position:absolute;left:-20px;top:12px;width:16px;height:1px;background:#30363d}
details{margin:1px 0}
summary{cursor:pointer;padding:5px 10px;background:#161b22;border:1px solid #21262d;border-radius:5px;color:#e6edf3;font-weight:600;font-size:13px;display:flex;align-items:center;gap:6px;user-select:none}
summary:hover{background:#21262d;border-color:#58a6ff}
.fi{font-size:12px;color:#aaa;background:#21262d;padding:1px 5px;border-radius:3px;white-space:nowrap}
.fn{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.ct{font-size:10px;color:#555;background:#0d1117;padding:1px 5px;border-radius:8px;margin-left:4px}
.ab{font-size:10px;padding:2px 7px;border-radius:3px;border:1px solid #444;color:#aaa;background:transparent;white-space:nowrap}
.ab:hover{color:#fff;background:#30363d}
.of{border-color:#f0883e;color:#f0883e}.of:hover{background:#f0883e;color:#fff}
.sb{border-color:#d29922;color:#d29922}.sb:hover{background:#d29922;color:#fff}.sb.starred{background:#d29922;color:#fff}
.fi2{display:inline-flex;align-items:center;gap:6px;padding:3px 12px;border-radius:4px;color:#fff;font-size:12px;margin:1px 0;border:none;text-align:left}
.fi2:hover{filter:brightness(1.25)}
.file-exe{background:#b33a00}.file-xlsx{background:#1a7f37}.file-pdf{background:#bc4c00}
.file-docx{background:#1a56db}.file-pptx{background:#cf222e}.file-txt{background:#444}
.file-img{background:#6e40c9}.file-vid{background:#0d7a5f}.file-aud{background:#1a5276}.file-other{background:#333}
.fs{background:transparent;border:none;color:#d29922;font-size:13px;margin-left:3px}
.hidden{display:none!important}
</style>
</head>
<body>
<button id="fav-btn" onclick="document.getElementById('sidebar').classList.toggle('open')">★ 收藏</button>
<div id="sidebar">
  <h3>★ 我的收藏</h3>
  <div id="favList"><div style="color:#555;font-size:12px">點 ☆ 加入收藏</div></div>
  <hr class="sep">
  <h3>篩選類型</h3>
  <label class="flbl"><input type="checkbox" class="tf" value="exe" checked> EXE 程式</label>
  <label class="flbl"><input type="checkbox" class="tf" value="xlsx" checked> Excel</label>
  <label class="flbl"><input type="checkbox" class="tf" value="pdf" checked> PDF</label>
  <label class="flbl"><input type="checkbox" class="tf" value="docx" checked> Word</label>
  <label class="flbl"><input type="checkbox" class="tf" value="pptx" checked> PPT</label>
  <label class="flbl"><input type="checkbox" class="tf" value="txt" checked> 文字檔</label>
  <label class="flbl"><input type="checkbox" class="tf" value="img" checked> 圖片/影音</label>
  <label class="flbl"><input type="checkbox" class="tf" value="other" checked> 其他</label>
</div>
<div id="main">
  <div class="rt">[DIR] $rootEnc</div>
  <div class="tb">
    <input type="text" id="sbox" placeholder="搜尋檔案或資料夾名稱..." oninput="doSearch(this.value)">
    <button class="be" onclick="expandAll()">全部展開</button>
    <button class="bc" onclick="collapseAll()">全部收合</button>
  </div>
  <div class="stats">共 $fcnt 個資料夾、$filecnt 個檔案</div>
  <div id="tree">$treeHtml</div>
</div>
<script>
var favs=[];
try{favs=JSON.parse(localStorage.getItem('navfav')||'[]');}catch(e){favs=[];}

function escH(s){return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
function toURL(p){return 'file:///'+p.replace(/\\/g,'/');}

function renderFav(){
    var l=document.getElementById('favList');
    if(!favs.length){l.innerHTML='<div style="color:#555;font-size:12px">點 ☆ 加入收藏</div>';return;}
    var h='';
    favs.forEach(function(f,i){
        var ic=f.type==='folder'?'[DIR]':'[F]';
        var url=toURL(f.path)+(f.type==='folder'?'/':'');
        h+='<div class="fv"><span style="color:#aaa;font-size:10px">'+ic+'</span>';
        h+='<span class="fvn" title="'+escH(f.path)+'">'+escH(f.name)+'</span>';
        h+='<a class="fvop" href="'+escH(url)+'" target="_blank">開啟</a>';
        h+='<button class="fvx" onclick="rmFav('+i+')">x</button></div>';
    });
    l.innerHTML=h;
}

function toggleFav(el){
    var path=el.getAttribute('data-path');
    var name=el.getAttribute('data-name');
    var type=el.getAttribute('data-type');
    var i=favs.findIndex(function(f){return f.path===path;});
    if(i>-1){favs.splice(i,1);el.textContent='☆';el.classList.remove('starred');}
    else{favs.push({path:path,name:name,type:type});el.textContent='★';el.classList.add('starred');}
    try{localStorage.setItem('navfav',JSON.stringify(favs));}catch(e){}
    renderFav();
}

function rmFav(i){
    favs.splice(i,1);
    try{localStorage.setItem('navfav',JSON.stringify(favs));}catch(e){}
    renderFav();
    syncStars();
}

function syncStars(){
    document.querySelectorAll('.sb,.fs').forEach(function(e){e.textContent='☆';e.classList.remove('starred');});
    favs.forEach(function(f){
        document.querySelectorAll('.sb,.fs').forEach(function(e){
            if(e.getAttribute('data-path')===f.path){e.textContent='★';e.classList.add('starred');}
        });
    });
}

function doSearch(k){
    var items=document.querySelectorAll('#tree li');
    if(!k){items.forEach(function(l){l.classList.remove('hidden');});return;}
    var kw=k.toLowerCase();
    items.forEach(function(l){
        var t=l.textContent.toLowerCase();
        if(t.indexOf(kw)>-1){
            l.classList.remove('hidden');
            var p=l.parentElement;
            while(p&&p.id!=='tree'){
                if(p.tagName==='DETAILS')p.open=true;
                if(p.tagName==='LI')p.classList.remove('hidden');
                p=p.parentElement;
            }
        }else{l.classList.add('hidden');}
    });
}

function expandAll(){document.querySelectorAll('details').forEach(function(d){d.open=true;});}
function collapseAll(){document.querySelectorAll('details').forEach(function(d){d.open=false;});}

document.querySelectorAll('.tf').forEach(function(cb){
    cb.addEventListener('change',function(){
        var t=this.value,s=this.checked;
        document.querySelectorAll('#tree li[data-type="'+t+'"]').forEach(function(l){
            l.classList.toggle('hidden',!s);
        });
    });
});

window.onload=function(){renderFav();syncStars();};
</script>
</body>
</html>
"@

try {
    [System.IO.File]::WriteAllText($OutputFile, $fullHtml, (New-Object System.Text.UTF8Encoding($true)))
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host "  [完成] 導航地圖已生成！" -ForegroundColor Green
    Write-Host "  位置: $OutputFile" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
    Start-Process $OutputFile
} catch {
    Write-Host "[錯誤] 寫入失敗: $($_.Exception.Message)" -ForegroundColor Red
    $null = Read-Host "Press Enter to exit"
}
