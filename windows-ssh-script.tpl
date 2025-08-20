add-content -path "C:/users/Nicholas Mutua/.ssh/config" -value @"
Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
"@
