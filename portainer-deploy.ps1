# Portainer'a Telegram Bot Deploy Scripti (Windows PowerShell)

param(
    [string]$PortainerUrl = "http://localhost:9000",
    [string]$PortainerToken = $env:PORTAINER_TOKEN,
    [string]$Action = "deploy"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Telegram Bot - Portainer Deploy" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Kontrol
if ([string]::IsNullOrEmpty($PortainerToken)) {
    Write-Host "⚠️  PORTAINER_TOKEN tanımlanmadı!" -ForegroundColor Yellow
    Write-Host "Kullanım: powershell -ExecutionPolicy Bypass -File portainer-deploy.ps1"
    Write-Host "Ortam değişkeni ayarla: `$env:PORTAINER_TOKEN = 'your-token'"
    exit 1
}

# .env dosyası kontrol et
if (!(Test-Path ".env")) {
    Write-Host "❌ .env dosyası bulunamadı!" -ForegroundColor Red
    Write-Host "Çözüm: Copy-Item .env.example .env ve doldur" -ForegroundColor Yellow
    exit 1
}

# .env dosyasını oku
$env_vars = @{}
Get-Content ".env" | ForEach-Object {
    if ($_ -match "^([^=]+)=(.*)$") {
        $env_vars[$matches[1]] = $matches[2]
    }
}

$StackName = "telegram-bot"
$EndpointId = "1"
$BotToken = $env_vars['TELEGRAM_BOT_TOKEN']
$WebhookUrl = $env_vars['N8N_WEBHOOK_URL']
$ApiPort = $env_vars['API_PORT'] -or "5000"

Write-Host "📝 Stack Bilgileri:" -ForegroundColor Green
Write-Host "  Name: $StackName"
Write-Host "  Portainer URL: $PortainerUrl"
Write-Host "  Bot Token: $($BotToken.Substring(0,10))***"
Write-Host "  N8N Webhook: $($WebhookUrl.Substring(0,30))***"
Write-Host ""

# Docker Compose dosyasını oku
$ComposeContent = Get-Content "docker-compose.yml" -Raw

# JSON escape
$ComposeEscaped = $ComposeContent -replace '"', '\"' -replace "`n", " "

# Stack payload
$Payload = @{
    Name = $StackName
    StackFileContent = $ComposeEscaped
    Env = @(
        @{ name = "TELEGRAM_BOT_TOKEN"; value = $BotToken },
        @{ name = "N8N_WEBHOOK_URL"; value = $WebhookUrl },
        @{ name = "API_PORT"; value = $ApiPort },
        @{ name = "DEBUG"; value = $env_vars['DEBUG'] -or "false" },
        @{ name = "LOG_LEVEL"; value = $env_vars['LOG_LEVEL'] -or "INFO" },
        @{ name = "REQUEST_TIMEOUT"; value = $env_vars['REQUEST_TIMEOUT'] -or "10" }
    )
} | ConvertTo-Json

# Stack zaten var mı kontrol et
Write-Host "🔍 Stack durumu kontrol ediliyor..." -ForegroundColor Yellow

try {
    $CheckResponse = Invoke-WebRequest -Uri "$PortainerUrl/api/stacks?name=$StackName" `
        -Headers @{"Authorization" = "Bearer $PortainerToken"} `
        -UseBasicParsing `
        -ErrorAction Stop

    $StackData = $CheckResponse.Content | ConvertFrom-Json
    
    if ($StackData.Count -gt 0) {
        $StackId = $StackData[0].Id
        Write-Host "⚠️  Stack zaten var (ID: $StackId)" -ForegroundColor Yellow
        Write-Host "Güncellemek için: portainer-deploy.ps1 -Action update" -ForegroundColor Cyan
    }
    else {
        $StackId = $null
    }
}
catch {
    $StackId = $null
}

# Deploy
if ($null -eq $StackId) {
    Write-Host "✅ Yeni stack oluşturuluyor..." -ForegroundColor Green
    
    try {
        $DeployResponse = Invoke-WebRequest -Uri "$PortainerUrl/api/stacks?type=2&method=string&endpointId=$EndpointId" `
            -Method Post `
            -Headers @{"Authorization" = "Bearer $PortainerToken"; "Content-Type" = "application/json"} `
            -Body $Payload `
            -UseBasicParsing

        $DeployData = $DeployResponse.Content | ConvertFrom-Json
        $StackId = $DeployData.Id
        
        Write-Host "✅ Stack oluşturuldu! ID: $StackId" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Stack oluşturma başarısız!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "✅ Deploy başarılı!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Portainer URL: $PortainerUrl" -ForegroundColor Cyan
Write-Host "📦 Stack: $StackName" -ForegroundColor Cyan
Write-Host "🆔 Stack ID: $StackId" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sonraki adımlar:" -ForegroundColor Yellow
Write-Host "  1. Portainer'a giriş yap: $PortainerUrl" -ForegroundColor Gray
Write-Host "  2. Stacks → $StackName → view in compose" -ForegroundColor Gray
Write-Host "  3. Containers → telegram-bot → logs" -ForegroundColor Gray
Write-Host ""
