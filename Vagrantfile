Vagrant.require_version ">= 1.8.0"

Vagrant.configure(2) do |config|
  config.vm.box = "opensuse/Leap-15.4.x86_64"
  config.vm.define "machine1"

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.groups = {
      "trento-server" => ["machine1"],
      "postgres-hosts" => ["machine1"],
      "prometheus-hosts" => ["machine1"],
      "rabbitmq-hosts" => ["machine1"]
    }
    ansible.extra_vars = {
      web_postgres_password: "pass",
      wanda_postgres_password: "wanda",
      rabbitmq_password: "trento",
      nginx_vhost_filename: "trento.conf",
      prometheus_url: "http://localhost",
      web_admin_password: "adminpassword",
      trento_server_name: "trento.local",
      nginx_ssl_cert_as_base64: "false",
      nginx_ssl_key_as_base64: "false",
      nginx_ssl_cert: "
-----BEGIN CERTIFICATE-----
MIIEZDCCA0ygAwIBAgIUAue46Y/9kwT+zvPPW2xfuNv1+Z4wDQYJKoZIhvcNAQEL
BQAwXjELMAkGA1UEBhMCSVQxFTATBgNVBAcMDERlZmF1bHQgQ2l0eTEcMBoGA1UE
CgwTRGVmYXVsdCBDb21wYW55IEx0ZDEaMBgGA1UEAwwRdHJlbnRvLmxvY2FsOjgw
ODAwHhcNMjQwMTIzMTUyODE1WhcNMzQwMTIwMTUyODE1WjBeMQswCQYDVQQGEwJJ
VDEVMBMGA1UEBwwMRGVmYXVsdCBDaXR5MRwwGgYDVQQKDBNEZWZhdWx0IENvbXBh
bnkgTHRkMRowGAYDVQQDDBF0cmVudG8ubG9jYWw6ODA4MDCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBALUvsN1zqhho08Ixdt55QuOpk21dAzBNkLf126FL
95285571KHPXLYmJB4fyrQOThFhNb8khtwJ9/R5Bo4xe/4RJKBMfVlklTw0/Vb76
1EuTta2ei0SsvoVvxB/x0gUYDH3zhKjyTJXdmlBT8B4qTj6PAHpVkbvwOKQJxVz0
zIIWYjOEVFERcVu0PGPPbLSBgedP+0izw/mq8C6OehrvYEIiHHWmCYtPctZFw5lh
F/Tt1erpFnX46TuwR5mujUvrAJLh3ytzJkLKaqD3mYzURtxrczYxGkztAvFmRDGu
lIFgXjWbTa5HUrRAa0SajJlQyxjA79Pgj6DgClgDFr7Ra9ECAwEAAaOCARgwggEU
MB0GA1UdDgQWBBQjO0boaaNuXxFgSn3ESPJKdJ/tyDCBmwYDVR0jBIGTMIGQgBQj
O0boaaNuXxFgSn3ESPJKdJ/tyKFipGAwXjELMAkGA1UEBhMCSVQxFTATBgNVBAcM
DERlZmF1bHQgQ2l0eTEcMBoGA1UECgwTRGVmYXVsdCBDb21wYW55IEx0ZDEaMBgG
A1UEAwwRdHJlbnRvLmxvY2FsOjgwODCCFALnuOmP/ZME/s7zz1tsX7jb9fmeMAwG
A1UdEwQFMAMBAf8wCwYDVR0PBAQDAgL8MBwGA1UdEQQVMBOCEXRyZW50by5sb2Nh
bDo4MDgwMBwGA1UdEgQVMBOCEXRyZW50by5sb2NhbDo4MDgwMA0GCSqGSIb3DQEB
CwUAA4IBAQAFCeRnF4lli/yn/aRHnwhs5H/G8s9O2X2qmohJG5AK3sZlK8gEXjhE
jiCailneKLBbu2WeT42Bg9AId94Nr4aDT7UlOYnhwk3WeMeFeEyH2QA1NzU23QFW
yMGFP0TUuENjMRYTgCsxvvsdhZ0/TqA8dYItKgpjVww7urRuKGJEFsf+wqQHKRTp
nOUlSPiGZ6xKJtRbpO6WSu2EkvQteA9HGS5qAqYbeJ7+ED+AE+fTQp3YwzhGl3G1
/3inS6wEPch/h0eJDSClXNYOApf6xRjUGcJ2XmutUdJq+MZ789WayQ1xjYPUSyCD
vzczKRPmQOQbiu02WM2hivWtPBH//A5N
-----END CERTIFICATE-----
      ",
      nginx_ssl_key: "
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC1L7Ddc6oYaNPC
MXbeeULjqZNtXQMwTZC39duhS/edvOee9Shz1y2JiQeH8q0Dk4RYTW/JIbcCff0e
QaOMXv+ESSgTH1ZZJU8NP1W++tRLk7WtnotErL6Fb8Qf8dIFGAx984So8kyV3ZpQ
U/AeKk4+jwB6VZG78DikCcVc9MyCFmIzhFRREXFbtDxjz2y0gYHnT/tIs8P5qvAu
jnoa72BCIhx1pgmLT3LWRcOZYRf07dXq6RZ1+Ok7sEeZro1L6wCS4d8rcyZCymqg
95mM1Ebca3M2MRpM7QLxZkQxrpSBYF41m02uR1K0QGtEmoyZUMsYwO/T4I+g4ApY
Axa+0WvRAgMBAAECggEAAs31Gamfy0UuUVVEUvz/3xS2jhtIY619rrIUHY1QTPbt
HTG/BK0C3M9CaGh5ZMKz3WbxP4tUreNfASjQfa/Rc9eEjE6gWE/ajYWELKK6DMOI
BnYVT1SyFcNrpVFwGALxAlv8IV48kOP9wdEzMfcjOZA4PtlQ4LHfFJK8pSigx9r6
KU4m8aAEiZi8uq3AWWwL18Y6HO03jyYGCOkZs3xK/wBW6loJWt7vvI42MN8GQkLE
t6CG+PlgWmi7PrsuKS7hItJgu7KVzDKXtbmo0nOqbRCKeSv30pj6R5Ujcn07lK7I
Ed65tQjkgsESlY23g0+E1uKsT1QIS8sutfoMEpszaQKBgQD3HUJh5feyBFrW6kiy
RKUPTKpKxsqWcEpwH5P9m7gZjr0l5oHaCtAS0GBd3UklQx+9DOuvSFAxPWG+VARI
IFdA80LbhuvSqV+7weUbNwIcSnUu7+4oGejk/zonsTKxwYe5hL05jM+trdGkkRvo
hrQ47FQ2MJm2cylrSL1O0Hp46QKBgQC7s4zNqV+sUoEEQwCntLmS+GgNx1iq7Ibx
89QK7Q6WersLi4nVmNCIODrL/SkeraJeZLUIXdDcvZlt4bFWmTx3EECJKoVL1/Q0
YlNx/FZYZBqcCr6hBhovbpMkbOFxX3Xuo2FMf7++tBrEwFom3r/9Wx1KMGkum73G
Sv9vlDqKqQKBgAg9IH51FVoJDSJHM19GLJ6i9raBhDWZztGIK/3zmCK6AJJn6gJk
A+XsrpnSi+LDJya9bIouhgXuPvkCghYJhf8zXRJGoEwou3leEI5kuhxJWzjSZQVP
P9WKsNyr6r3Ebwr/YvOtPytSNUAgWmbZPt76+h/IZQeRNVtPVIhxKPQpAoGABB/N
2DcAgyjM7OsL+KNf8HrEzoiyyg6oaGiTICpVR7kqovZN8QOKkXOq1xCY9rOZ/bj4
wVZOYItJ88AhxWVYjsUspdbpVuFH3F7MtpR00Txh2UvjJGad7KzhTsuVqIgQb03n
tWaZL/eFHw2a7X+3eDmoSxkFNqD1aoX7VthK8QECgYEAs99HdXW9LlGQeoUrG5UX
14Zm7CH/6TtwdWFpbcppJpipEtbDHyjpyiDlrgI4uxVilPnrBQtgzHCf8U2xQDJF
l0GpzDqUXDQI3wdzi8gVUBgPpjfVa9msafc7m6faT8myjHr/p6TJKj9Z36j58WHv
mpNiKDOPALNTs+Ukdkt5KlE=
-----END PRIVATE KEY-----
      "
    }
  end
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8443
end