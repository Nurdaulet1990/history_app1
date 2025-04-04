@echo off
mkdir app 2>nul
echo Generating keystore...
keytool -genkeypair ^
-v ^
-keystore app/upload-keystore.jks ^
-alias history_quiz_key ^
-keyalg RSA ^
-keysize 2048 ^
-validity 10000 ^
-storepass history123 ^
-keypass history123 ^
-dname "CN=Your Name, OU=Development, O=History Quiz App, L=Your City, ST=Your State, C=KZ"
echo Done! Keystore generated at app/upload-keystore.jks
pause 