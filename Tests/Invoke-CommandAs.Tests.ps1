BeforeDiscovery {
    Try { Set-BuildEnvironment -Path "${PSScriptRoot}\.." -ErrorAction SilentlyContinue -Force } Catch { }

    Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue -Force -Confirm:$False
    $Script:Module = Import-Module $ENV:BHPSModuleManifest -Force -PassThru
    
    $runsElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
}

BeforeAll {
    Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue -Force -Confirm:$False
    $Script:Module = Import-Module $ENV:BHPSModuleManifest -Force -PassThru
}


Describe 'Get-Module -Name Invoke-CommandAs' {
    Context 'Strict mode' {

        Set-StrictMode -Version Latest

        It 'Should Import' {
            $Script:Module.Name | Should -Be $ENV:BHProjectName
        }
        It 'Should have ExportedFunctions' {
            $Script:Module.ExportedFunctions.Keys -contains 'Invoke-CommandAs' | Should -Be $True
        }
    }
}

Describe 'InvokeAs current user' {
    It 'Should return an object' {
        $result = Invoke-CommandAs { [System.Security.Principal.Windowsidentity]::GetCurrent() }
        $result | Should -BeOfType ([System.Security.Principal.WindowsIdentity])
    }
    It 'Should return an object by parameter' {
        $result = Invoke-CommandAs -ScriptBlock { param($a) "There was something $a" } -Argumentlist 'from outside'
        $result | Should -Be "There was something from outside"
    }
    It 'Should return an error object' {
        { Invoke-CommandAs { 1/0 } } | Should -Throw
    }
}

Describe 'Only in an elevated session' -Skip:(-Not $runsElevated) {
    It 'Should return an deserialized object' {
        $result = Invoke-CommandAs {
            [System.Security.Principal.Windowsidentity]::GetCurrent()
        } -AsSystem
        $result.psobject.typenames | Should -Contain 'Deserialized.System.Security.Principal.WindowsIdentity'
    }
    Context 'CoreCLR' -Skip:(-Not $isCoreCLR) {
        It 'Should return an deserialized error object' -Skip:(-Not $runsElevated -or -Not $isCoreCLR) {
            $result = Invoke-CommandAs {
                1/0
            } -AsSystem
            $result.psobject.typenames | Should -Contain 'Deserialized.System.Management.Automation.ErrorRecord'
        }
    }
    Context 'Windows Powershell' -Skip:($isCoreCLR) {
        # PS5.1 seems not to return a "native" error record
        It 'Should return an deserialized error object' -Skip:(-Not $runsElevated -or $IsCoreCLR) {
            $result = Invoke-CommandAs {
                1/0
            } -AsSystem -ErrorAction SilentlyContinue
            $result.psobject.typenames | Should -Contain 'System.Management.Automation.PSCustomObject'
        }
    }
}

