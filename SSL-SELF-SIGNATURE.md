## 1. Generate Private Key
```bash
openssl genrsa -out private-key.pem 2048
```

## 2. Generate Certificate Signing Request (CSR)
```bash
openssl req -new -key private-key.pem -out csr.pem
```
Country Name (C): ID (atau kode negara lainnya)
State or Province Name (ST): Yogyakarta
Locality Name (L): Yogyakarta
Organization Name (O): MyCompany
Organizational Unit Name (OU): IT
Common Name (CN): your-domain.com (atau alamat ELB jika belum punya domain) [elb-tirtahakimp35-872957266.us-east-1.elb.amazonaws.com](http://elb-tirtahakimp35-2127368026.us-east-1.elb.amazonaws.com/)
Email Address: admin@your-domain.com

## 3. Generate Self-Signed Certificate
```bash
openssl x509 -req -days 365 -in csr.pem -signkey private-key.pem -out certificate.pem
```
elb-tirtahakimp35-854888168.us-east-1.elb.amazonaws.com