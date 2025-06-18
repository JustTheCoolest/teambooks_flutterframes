import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import {  } from "firebase/cloud_functions"

const auth = getAuth();
signInWithEmailAndPassword(auth, 'volunteer@teambooks.org', 'admin123')
  .then((userCredential) => {
    // Signed in 
    const user = userCredential.user;

    // ...
  })
  .catch((error) => {
    const errorCode = error.code;
    const errorMessage = error.message;
  });