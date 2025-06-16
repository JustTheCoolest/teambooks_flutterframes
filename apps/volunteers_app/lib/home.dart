/*
@public
CloudFunction validateVolunteer(){
  volunteerUID = getCurrentUserUID()
  return firestore.exists((collection:volunteers)/(volunteerUID))
}

@public
CloudFunction checkPhoneNumberExists(phone number) {
  return firestore.exists((collection:donors)/(phone number))
}

@private
String addDonorDetails(Donor Details) {
  firestore.put((collection:donors)/(donorID: phone number ?? auto-gen)/{
    DonorDetails
  })
  return donorID
}

@public
@cache(ttl: 10 minutes)
CloudFunction getBookDetails(ISBN) {
  return api.fetchDetails(ISBN) {
    title,
    author,
    publisher,
    genre,
  }
}

@private
CloudFunction registerBookToCatalog(DonorID, List[ISBNs]) {
  List[Copies] init
  for (ISBN in List[ISBNs]):
    book = firestore.get((collection:catalog)/(bookID:auto-gen))
    book.put((collection:copies)/(copyID:auto-gen)/{
      fullID: bookID+copyID,
      donorID,
      volunteerUID,
      ISBN,
      getBookDetails(ISBN),
    })
    Copies.addToList('booksRegistered', fullID)
  return Copies
}

@public
CloudFunction addBookToCatalog(Donor Details, List[ISBNs]) {
  throwable: validate request is from volunteer 
  donorID = checkPhoneNumberExists(Donor Details.phone number) ?? addDonorDetails(Donor Details)
  Copies = registerBookToCatalog(donorID, List[ISBNs])
  Receipt = generateReceipt(volunteer, donor, Copies)
  Email(to: donor.email, body: Receipt)
  log()
  return Receipt
}

ActualHome(
  Button(
    text: 'Register Book',
    onPressed: () {
      FullScreenDialog(
        Form(
          (phone number ?? null).ifExists() ? showDonorDetails() : collectDonorDetails(),
          Donor Details (anonymysable) {
            Phone Number,
            Name,
            Company/ Apartment : Dynamic List with Create Option,
          }
          int Number Of Books {
            ISBN : verify book details from API (),
          }
          onSubmit: call addBookToCatalog(Donor Details {phone number / full details}, List[ISBNs]) -> wait load -> show Receipt()
        )
      )
    },
  )
)

ShowReceipt(Receipt) {
  "The donor will also receive a copy of this receipt via email.",
  Receipt,
  Button(text: 'Close', onPressed: closeDialog),
} 

AccessDeniedScreen{
  show(UID) with instructions to paste in form,
  prompt form filling in case user didn't come from the form,
}

Home(
  validateVolunteer() ? ActualHome() : AccessDeniedScreen(),
)
*/
