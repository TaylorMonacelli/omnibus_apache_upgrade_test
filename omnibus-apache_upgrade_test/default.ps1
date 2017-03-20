Task default -Depends Test1

Task Test1 {

    Get-MSIRelatedProductInfo -UpgradeCode '{650bc54a-bf6f-403e-89e7-49bb2b02b6f5}' | %{
        Start-Process -Wait -FilePath msiexec -ArgumentList /X, $_.ProductCode, /qn
    }

    $httpd_path = 'C:\windows\temp\apache-upgrade-test\apache\bin\httpd.exe'
    Assert(!(test-path $httpd_path)) "Expecting $httpd_path should be gone from uninstall"

    # apache2.4.23
    (Get-Content "config/projects/apache_upgrade_test.rb") `
	  -replace 'dependency "apache\d+"', 'dependency "apache23"' `
	  | Set-Content -Encoding ascii "config/projects/apache_upgrade_test.rb"

    ruby bin/omnibus build apache_upgrade_test --log-level warn
    $msi=(gci $pwd/pkg/apache-upgrade-test*.msi | select fullname -last 1).FullName
    rm -ea 0 -force "install_apache23.log"
    Start-Process -Wait -FilePath msiexec -ArgumentList /i, `
	  "$msi", /qn, /l*v, "install_apache23.log", PROJECTLOCATION='"C:\windows\temp\apache-upgrade-test"'

    $output = & "C:\windows\temp\apache-upgrade-test\apache\bin\httpd.exe" -version
    $regex_version = '((\d+\.)?(\d+\.)?(\*|\d+))'
    $version = [regex]::match($output,"Apache/$regex_version").Groups[1].Value
    Assert('2.4.23' -eq $version) "Expecting apache v2.4.23, but instead got version $version"

    # apache2.4.25
    (Get-Content "config/projects/apache_upgrade_test.rb") `
	  -replace 'dependency "apache\d+"', 'dependency "apache25"' `
	  | Set-Content -Encoding ascii "config/projects/apache_upgrade_test.rb"

    ruby bin/omnibus build apache_upgrade_test --log-level warn
    $msi=(gci $pwd/pkg/apache-upgrade-test*.msi | select fullname -last 1).FullName
    rm -ea 0 -force "install_apache25.log"
    Start-Process -Wait -FilePath msiexec -ArgumentList /i, `
	  "$msi", /qn, /l*v, "install_apache25.log", PROJECTLOCATION='"C:\windows\temp\apache-upgrade-test"'

    $output = & "C:\windows\temp\apache-upgrade-test\apache\bin\httpd.exe" -version
    $regex_version = '((\d+\.)?(\d+\.)?(\*|\d+))'
    $version = [regex]::match($output,"Apache/$regex_version").Groups[1].Value
    Assert('2.4.25' -eq $version) "Expecting apache v2.4.25, but instead got version $version"
}

Task Clean {
    rm -ea 0 -recurse pkg
    rm -ea 0 install_apache*.log
}
