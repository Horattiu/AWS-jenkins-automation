# AWS Jenkins Automation

Acesta este un proiect care folosește AWS, Terraform, Ansible și Python pentru a automatiza crearea unei instanțe EC2, configurarea acesteia cu un server web Apache, asocierea unui Elastic IP și trimiterea unui email de notificare atunci când site-ul devine live. Jenkins a fost folosit pentru a orchestra și rula acest proiect, deși fișierele sunt gestionate direct în Jenkins UI.

## Fișierele din proiect

### 1. `main.tf` (Terraform)

Fișierul `main.tf` este folosit pentru a configura infrastructura pe AWS folosind Terraform. În acest fișier, am definit următoarele resurse:

- **Provider AWS**: Setează regiunea în care vor fi create resursele AWS (în acest caz, `eu-west-1`).
  
- **Security Group**: Creează un grup de securitate pentru a permite acces SSH pe portul 22, HTTP pe portul 80 și HTTPS pe portul 443. De asemenea, sunt definite reguli pentru a permite orice trafic de ieșire.
  
- **Instanța EC2**: Se creează o instanță EC2 pe baza unui AMI specific (în acest caz, `ami-03fd334507439f4d1`), de tipul `t2.micro`, care este o instanță de tip gratuit disponibilă pentru AWS.
  
- **Asocierea Elastic IP**: După ce instanța este creată, se asociază un Elastic IP la instanță, asigurând astfel accesul public la instanță. Elastic IP-ul este esențial pentru a menține o adresă IP statică pe care o putem folosi pentru a accesa serverul.

### 2. `inventory.ini` (Ansible)

Fișierul `inventory.ini` este folosit pentru a defini hosturile pe care Ansible le va configura. În acest fișier, se adaugă IP-ul instanței EC2 care a fost creată anterior. Se definește utilizatorul SSH (`ubuntu`) și calea către cheia privată necesară pentru autentificare SSH.

- **Hosturi**: Ansible va accesa instanța EC2 folosind adresa IP asociată și va executa comenzi pentru configurarea serverului.
  
- **Cheie SSH**: Se specifică calea către cheia privată SSH (`/var/lib/jenkins/.ssh/Horatiu_project.pem`) care va fi folosită pentru a autentifica conexiunea la instanță.

### 3. `playbook.yml` (Ansible)

Fișierul `playbook.yml` este folosit de Ansible pentru a automatiza configurarea serverului web pe instanța EC2. Acesta conține următoarele task-uri:

- **Instalare Apache**: Se instalează serverul web Apache pe instanța EC2 folosind comanda `apt` din Ansible.
  
- **Pornire Apache**: După instalare, Apache este pornit și setat să pornească automat la boot.
  
- **Crearea paginii HTML**: Se creează o pagină HTML simplă care confirmă că site-ul este live. Pagina este salvată în directorul web root al serverului Apache.

### 4. `send_email.py` (Python)

Fișierul `send_email.py` folosește `boto3`, biblioteca Python pentru AWS, pentru a trimite un email folosind Amazon SES (Simple Email Service). Acest script trimite un email de notificare către o adresă specificată atunci când site-ul este live.

- **Configurația SES**: Folosește AWS SES pentru a trimite un email dintr-o adresă de email (setată în variabila `Source`) către o altă adresă de email (setată în variabila `Destination`).
  
- **Subiect și corpul mesajului**: Email-ul are un subiect și un corp specific care anunță că site-ul este live.

---

## Cum funcționează

1. **Terraform** creează infrastructura pe AWS: instanța EC2, grupul de securitate și asocierea Elastic IP.
2. **Ansible** este folosit pentru a configura serverul web Apache pe instanța EC2.
3. **Python** trimite un email pentru a confirma că site-ul este live.
4. **Jenkins** orchestrează pașii folosind un script scris în Jenkins UI.

---

## Scriptul Jenkins

În Jenkins, am folosit un script pentru a automatiza pașii de Terraform și Ansible, precum și trimiterea unui email folosind Python. Scriptul face următoarele:

1. **Inițializează Terraform**: Comanda `terraform init` inițializează directorul de lucru pentru Terraform.
2. **Rulează Terraform Apply**: Comanda `terraform apply -auto-approve -lock=false` creează infrastructura pe AWS (instanța EC2, grupul de securitate, etc.). Dacă comanda reușește, se afișează un mesaj de succes.
3. **Așteaptă 200 de secunde**: Se așteaptă ca instanța EC2 să se inițializeze înainte de a continua.
4. **Rulează Ansible**: Folosește Ansible pentru a configura serverul web Apache pe instanța EC2.
5. **Trimite un email**: După configurarea serverului, se trimite un email de notificare folosind scriptul Python `send_email.py`.

```bash
ls
pwd
export ANSIBLE_HOST_KEY_CHECKING=False
terraform init
terraform apply -auto-approve -lock=false
if [ $? -eq 0 ]; then
    echo "Command succeeded!"
else
    echo "Command failed!"
fi

echo "Terraform ran succesfully!"
echo "Waiting for ec2 instance to initialize..."
echo "Hecher sunt hecher ma cheama am putere nu mi-e teama"
echo "Sleeping for 100 seconds...grab a coffee"
sleep 200

echo "Trying now to run ansible..."
ansible-playbook playbook.yml -i inventory.ini --private-key=/var/lib/jenkins/.ssh/Horatiu_project.pem
if [ $? -eq 0 ]; then
    echo "Command succeeded!"
else
    echo "Command failed!"
fi

python3 send_email.py
