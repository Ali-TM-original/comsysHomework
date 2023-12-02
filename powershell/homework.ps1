param(
    [Parameter(Mandatory=$True, Position=0)] [string]$flag,
    [Parameter(Mandatory=$False, Position=1)] [string]$extraArgs
)


function HelpUtil {
    Write-Host "Description of the script here"
    Write-Host
    Write-Host "Syntax: [-list | -student | -max | -h ]"
    Write-Host "                                Options"
    Write-Host "-------------------------------------------------------------------------"
    Write-Host "| Command    | parameter    | Usage                                     |"
    Write-Host "|-----------------------------------------------------------------------|"
    Write-Host "| -h         |              | Displays this help message                |"
    Write-Host "| -list      | teacher name | Lists names of course belonging to teacher|"
    Write-Host "| -student   | student name | Lists teachers who teach the student      |"
    Write-Host "| -max       |              | Prints name of teacher with most courses  |"
    Write-Host "------------------------------------------------------------------------ "
}


function ArgChecker{
    if([string]::IsNullOrEmpty($extraArgs)){
        Write-Warning "Student Name is Null"
        HelpUtil
        Exit 1
     }    
    
}

function ListFunction{
    $File = ".\teams.dat"
    $Final = @()
    $content = Get-Content -Path $File

    forEach($line in $content){
        $Course, $TeamsCode, $Teacher = $line.Split(",")
        
        if($Teacher.Trim() -eq $extraArgs){
            $Final+="| $Course"
        }
    }
    Write-Host "$extraArgs Teaches the following subjects: "
    Write-Host $Final
}

# This is so slow lmao
function MaxFunction{
    $File = ".\teams.dat"
    $Final = @{}
    $content = Get-Content -Path $File

    forEach($line in $content){
        $Course, $TeamsCode, $Teacher = $line.Split(",")
        $test = $Final[$Teacher.Trim()]
        if([string]::IsNullOrEmpty($test)){
            $Final[$Teacher.Trim()] = 0
        }
        $Final[$Teacher.Trim()] = $test + 1   
    }

    $names= @()
    $count = @()
    foreach ($entry in $Final.GetEnumerator()) {
        $count+=$entry.value
        $names+=$entry.key
    }
    # Get the maximum value
    $maxValue = ($count | Measure-Object -Maximum).Maximum

    # Get the index of the maximum value
    $index = $count.IndexOf($maxValue)
    Write-Host $names[$index]
}


function Student{
    $StudentClasses = @() # we got this baby now compare it with teachers
    $StudentContent = Get-Content -Path ".\students.dat"
    forEach($line in $StudentContent){
        $elements = $line -split ","
        if($elements[0].Trim() -eq $extraArgs){
            $classCodes = $elements[1..($elements.Length - 1)]
            $StudentClasses += $classCodes
        }
    }
    $StudentClasses = $StudentClasses | ForEach-Object { $_.Trim() }

    $FinalTeachers = @()
    $teacherContent = Get-Content -Path ".\teams.dat"
    forEach($line in $teacherContent){
        $Course, $TeamsCode, $Teacher = $line.Split(",")
        if($StudentClasses -contains $TeamsCode.Trim()){
            if(-not ($FinalTeachers -contains $Teacher)){$FinalTeachers+="|$Teacher"}
        }
        
    }
    Write-Host "Teachers that teach $extraArgs are: "
    Write-Host $FinalTeachers
}

switch($flag){
    "-h" {
        HelpUtil
        Exit 1
    }
    "-list" {
        ArgChecker
        ListFunction
        Exit 1
    }
    "-student" {
        ArgChecker
        Student
        Exit 1
    }
    "-max"{
        MaxFunction
        Exit 1
    }
    Default {
        HelpUtil
        Exit 1
    }
}