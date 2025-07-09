# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn, options, firestore_fn
from firebase_admin import initialize_app, firestore
import requests
import uuid
# from datetime import datetime, timedelta # TODO: add to requirements.txt if used for @cache

initialize_app()

options.set_global_options(region=options.SupportedRegion.ASIA_SOUTH1) 

db = firestore.client()

@https_fn.on_request()
def helloworld(req: https_fn.Request) -> https_fn.Response:
    return https_fn.Response("Hello, World!")

def actual_validate_volunteer(volunteer_uid):
    user_doc = db.collection('users').document(volunteer_uid).get()
    return user_doc.exists and user_doc.to_dict().get('roles', {}).get('volunteer', False)

@https_fn.on_call()
def validate_volunteer(req: https_fn.CallableRequest):
    volunteer_uid = req.auth.uid if req.auth else None
    if not volunteer_uid:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required."
        )

    return actual_validate_volunteer(volunteer_uid)


'''
catalogQueue{
    donationId (auto-gen, doc id),
    donorId?,
    volunteerUid,
    "books" (isbns / manual book details): [isbn1, isbn2, ...],
    wasOffline,
    editDonorIntent,
    donorDetails: {
        name,
        phoneNumber,
        email,
        apartment/company, 
    },
    donation timestamp,
}

CloudFunction addBookToCatalog(...):
  Possibilities:
    1. Direct callable function
      - Requires internet connection
      - No scope for failure. Can use auto-gen for document IDs
    2. Directly add to catalog (with trigger)
      - Automatic Firestore offline support
      - Can there be doc ID conflicts when syncing with server?
      - Phone number can be used as donor ID, but sounds like it might cause privacy problems, and we won't be able to update it or create accounts for children 
      - Anonymous donors would still need auto-gen
      - Can make volunteer UID as part of anonymous donor ID, but even volunteer can have multiple devices
      - Can we assign IDs to volunteer devices?
      - Privacy problem with including volunteer UID in donor ID
      - Perhaps use clock time as part of ID / hash?
      - What if trigger fails even after syncing document?
    3. Buffer collection (with trigger)
      - All problems as before
      - Different auto-gen for doc IDs, might not be in sync
      - More robust against trigger failures
      - Can't locally create receipts as the book doc is not created yet, unless we use custom ids or sync ids
'''

'''
create_donor(...):
    - Donors have separate collection so that voluntters can read and write without privacy violations (?)
    - Future changes in phone number or email?
    - Document ID as the donor ID?
    - Should an actually user account also be created simulataneously?
    - In that case, what would be the relationship between the donor ID and user account ID?
    - Reads and writes can be done via CloudFunctions to protect privacy, even if using only the users collection
     (for avoiding ID complexity)
    - But separate donors collection may still be better for architectural changes in the future?
    - Enforce unique phone number
    - Enforce unique email?
    - Phone number is used as the main identifier in in-person drives (because simpler to listen and type), 
      but email would be the main identifier for sign ins into the platform?
    - Null values?
    - Sign ins forced to be using phone number instead of email IDs?
'''

# ============================================================================
# IMPLEMENTATION OF PSEUDOCODE FROM COMMENTS
# ============================================================================

def is_isbn(isbn):
    """
    Validates if a string is a valid ISBN-10 or ISBN-13.
    """
    if not isinstance(isbn, str):
        return False
    
    # Remove hyphens and spaces
    isbn = isbn.replace('-', '').replace(' ', '')
    
    # Check ISBN-10 (10 digits, last can be X)
    if len(isbn) == 10:
        return all(c.isdigit() for c in isbn[:-1]) and (isbn[-1].isdigit() or isbn[-1].upper() == 'X')
    
    # Check ISBN-13 (13 digits)
    if len(isbn) == 13:
        return all(c.isdigit() for c in isbn)
    
    return False

def is_book_details(book_data):
    """
    Validates if book_data contains manual book details instead of ISBN.
    """
    if not isinstance(book_data, dict):
        return False
    
    required_fields = ['title', 'author']
    return all(field in book_data for field in required_fields)

"""
PSEUDOCODE:
def create_donor(donor_details):
    assert phone_number and donor_email are unique
    donor_id = db.collection('donors').add({
        'name': donor_name,
        'email': donor_email,
        'phoneNumber': donor_phone,
        'apartment/company': donor_group,
        'books': []
    })
    cloud log: volunteer_uid created donor_id synced at current_time and done at donation_time
    return donor_id
"""
def create_donor(donor_details, volunteer_uid=None):
    """
    Creates a new donor with unique phone number and email validation.
    """
    phone_number = donor_details.get('phoneNumber')
    donor_email = donor_details.get('email')
    
    # Assert phone_number and donor_email are unique
    if phone_number:
        existing_phone = db.collection('donors').where('phoneNumber', '==', phone_number).limit(1).get()
        if len(existing_phone) > 0:
            raise ValueError(f"Phone number {phone_number} already exists")
    
    if donor_email:
        existing_email = db.collection('donors').where('email', '==', donor_email).limit(1).get()
        if len(existing_email) > 0:
            raise ValueError(f"Email {donor_email} already exists")
    
    # Create donor document
    donor_doc = {
        'name': donor_details.get('name'),
        'email': donor_email,
        'phoneNumber': phone_number,
        'apartment/company': donor_details.get('apartment/company'),
        'books': [],
        'createdAt': firestore.SERVER_TIMESTAMP
    }
    
    # Add donor to collection
    _, donor_ref = db.collection('donors').add(donor_doc)
    donor_id = donor_ref.id
    
    # Cloud log: volunteer_uid created donor_id synced at current_time and done at donation_time
    log_event("donor_created", {
        "volunteer_uid": volunteer_uid,
        "donor_id": donor_id,
        "synced_at": firestore.SERVER_TIMESTAMP,
        "donation_time": firestore.SERVER_TIMESTAMP
    })
    
    return donor_id

"""
PSEUDOCODE:
@https_fn.on_call()
def fetch_isbn(isbn):
    is_isbn(...)
    "https://openlibrary.org/dev/docs/api/books"
"""
@https_fn.on_call()
def fetch_isbn(req: https_fn.CallableRequest):
    """
    Fetches book details from OpenLibrary API using ISBN.
    """
    isbn = req.data.get('isbn')
    
    if not is_isbn(isbn):
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Invalid ISBN format"
        )
    
    # Clean ISBN for API call
    clean_isbn = isbn.replace('-', '').replace(' ', '')
    
    # OpenLibrary API
    api_url = f"https://openlibrary.org/isbn/{clean_isbn}.json"
    
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        data = response.json()
        
        # Extract book details
        book_details = {
            'title': data.get('title', 'Unknown Title'),
            'author': ', '.join([author.get('name', 'Unknown') for author in data.get('authors', [])]),
            'genre': data.get('subjects', ['Unknown'])[0] if data.get('subjects') else 'Unknown',
            'publisher': ', '.join(data.get('publishers', ['Unknown'])),
            'isbn': isbn,
            'cover_url': f"https://covers.openlibrary.org/b/isbn/{clean_isbn}-M.jpg"
        }
        
        return book_details
        
    except requests.exceptions.RequestException as e:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAVAILABLE,
            message=f"Failed to fetch book details: {str(e)}"
        )

def edit_donor(donor_id, donor_details, volunteer_uid):
    """
    Updates existing donor details.
    """
    donor_ref = db.collection('donors').document(donor_id)
    
    if not donor_ref.get().exists:
        raise ValueError(f"Donor {donor_id} does not exist")
    
    # Update donor details
    update_data = {}
    for field in ['name', 'email', 'phoneNumber', 'apartment/company']:
        if field in donor_details:
            update_data[field] = donor_details[field]
    
    if update_data:
        update_data['updatedAt'] = firestore.SERVER_TIMESTAMP
        donor_ref.update(update_data)
        
        # Log the edit
        log_event("donor_edited", {
            "volunteer_uid": volunteer_uid,
            "donor_id": donor_id,
            "updated_fields": list(update_data.keys()),
            "timestamp": firestore.SERVER_TIMESTAMP
        })

"""
PSEUDOCODE:
@firestore_fn.on_document_created(document_path='catalogQueue/{docId}')
def addBooksToCatalog(event: firestore_fn.Event):
    def validate_add_books_request(event):
        error = ValueError("Improper request (rejected)")
        isbns = event.data.get('isbns')
        assert all(is_isbn(isbn) or is_book_details(isbn) for isbn in isbns), error
    
    def handle_donor(...):
        if not donorId: 
            if not donorDetails:
                return anonymous
            return create_donor(donor_details) with log
        if editDonorIntent:
            edit_donor(donorId, donor_details) with log
            return donorId
        return donorId

    validate_add_books_request(event)
    donorId = handle_donor(...)
    init batch_writes 
    for book in books:
        if type(book) is isbn:
            book_details = fetch_isbn(isbn) {
                name, 
                author,
                genre,
                picture
            }
        else:
            book_details = book
        batch_writes.add(
            donationId,
            {book_details},
            volunteerUid,
            donorId,
            registrationDate=firestore.SERVER_TIMESTAMP,
            donationTimestamp
        )
    batch_writes.write() with each log
    update counters
"""
@firestore_fn.on_document_created(document="catalogQueue/{docId}")
def addBooksToCatalog(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]):
    """
    Firestore trigger that processes catalogQueue entries and adds books to catalog.
    """
    
    def validate_add_books_request(event_data):
        """Validates the catalog queue request data."""
        error = ValueError("Improper request (rejected)")
        isbns = event_data.get('isbns', [])
        
        if not isbns:
            raise error
            
        # Validate each item is either ISBN or book details
        for item in isbns:
            if not (is_isbn(item) or is_book_details(item)):
                raise error
                
        return True
    
    def handle_donor(donor_id, donor_details, edit_donor_intent, volunteer_uid):
        """Handles donor creation/editing logic."""
        if not donor_id:
            if not donor_details:
                return "anonymous"
            return create_donor(donor_details, volunteer_uid)
        
        if edit_donor_intent:
            edit_donor(donor_id, donor_details, volunteer_uid)
            return donor_id
            
        return donor_id
    
    try:
        # Get event data
        event_data = event.data.to_dict() if event.data else {}
        donation_id = event.params.get('docId')
        
        # Extract fields from catalogQueue document
        volunteer_uid = event_data.get('volunteerUid')
        isbns = event_data.get('isbns', [])
        donor_id = event_data.get('donorId')
        donor_details = event_data.get('donorDetails')
        edit_donor_intent = event_data.get('editDonorIntent', False)
        was_offline = event_data.get('wasOffline', False)
        donation_timestamp = event_data.get('timestamp')
        
        # Validate request
        validate_add_books_request(event_data)
        
        # Handle donor
        final_donor_id = handle_donor(donor_id, donor_details, edit_donor_intent, volunteer_uid)
        
        # Initialize batch writes
        batch = db.batch()
        book_count = 0
        
        # Process each book
        for book_item in isbns:
            try:
                if is_isbn(book_item):
                    # Fetch book details from API
                    book_details = get_book_details_internal(book_item)
                else:
                    # Use provided book details
                    book_details = book_item
                
                # Create book document in catalog
                book_ref = db.collection('catalog').document()
                book_data = {
                    'donationId': donation_id,
                    'volunteerUid': volunteer_uid,
                    'donorId': final_donor_id,
                    'registrationDate': firestore.SERVER_TIMESTAMP,
                    'donationTimestamp': donation_timestamp,
                    'wasOffline': was_offline,
                    **book_details
                }
                
                batch.set(book_ref, book_data)
                book_count += 1
                
                # Log each book addition
                log_event("book_added_to_catalog", {
                    "donation_id": donation_id,
                    "book_id": book_ref.id,
                    "volunteer_uid": volunteer_uid,
                    "donor_id": final_donor_id,
                    "isbn": book_details.get('isbn', 'manual_entry')
                })
                
            except Exception as e:
                log_event("book_processing_error", {
                    "donation_id": donation_id,
                    "book_item": str(book_item),
                    "error": str(e),
                    "volunteer_uid": volunteer_uid
                })
                continue
        
        # Execute batch write
        if book_count > 0:
            batch.commit()
            
            # Update counters/aggregates
            update_aggregates({
                "books_added": book_count,
                "volunteer_uid": volunteer_uid,
                "donor_id": final_donor_id,
                "donation_id": donation_id
            })
            
            log_event("catalog_queue_processed", {
                "donation_id": donation_id,
                "books_processed": book_count,
                "volunteer_uid": volunteer_uid,
                "donor_id": final_donor_id
            })
        else:
            log_event("catalog_queue_no_books", {
                "donation_id": donation_id,
                "volunteer_uid": volunteer_uid
            })
            
    except Exception as e:
        log_event("catalog_queue_error", {
            "donation_id": donation_id if 'donation_id' in locals() else 'unknown',
            "error": str(e),
            "event_data": event_data
        })
        raise e

@https_fn.on_call()
def check_phone_number_exists(req: https_fn.CallableRequest):
    """
    Checks if a donor with the given phone number already exists.
    """

    # log the read (not implemented here, assuming all reads are logged)

    validate_volunteer(req)

    def is_phone_number(value):
        return isinstance(value, str) and value[0]=="+" and value[1:].isdigit()

    phone_number = req.data.get('phoneNumber')
    if not is_phone_number(phone_number):
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Invalid data."
        )

    donors_ref = db.collection('donors')
    query = donors_ref.where('phoneNumber', '==', phone_number).limit(1)
    results = query.stream()

    donor_exists = any(results)

    if not donor_exists:
        return {"exists": False}

    donor_doc = results[0]
    donor_id = donor_doc.id
    donor_email = donor_doc.get('email')
    donor_phone = donor_doc.get('phoneNumber')
    donor_group = donor_doc.get('group')

    return {"exists": True, "donorId": donor_id, "email": donor_email, "phoneNumber": donor_phone, "group": donor_group}

def add_donor_details(donor_details):
    """
    Adds a new donor to the Firestore database.
    Generates a unique ID for the donor if not provided via phone number.
    """
    db = firestore.client()
    donors_ref = db.collection('donors')

    phone_number = donor_details.get('phoneNumber')
    donor_id = phone_number # Use phone number as ID if present

    if not donor_id:
        donor_id = str(uuid.uuid4()) # Generate a unique ID
        donor_details['donorId'] = donor_id # Add it to the details being stored

    donors_ref.document(donor_id).set(donor_details)
    return donor_id

# TODO: Implement caching if this API is called frequently and data is static enough.
# Firebase Functions themselves can be cached by CDN if configured.
# For in-function caching, a library like cachetools could be used with a TTL.
@https_fn.on_call()
def get_book_details(req: https_fn.CallableRequest):
    """
    Fetches book details from an external API using ISBN.
    (This is a placeholder and needs a real ISBN API)
    """
    isbn = req.data.get('isbn')
    if not isbn:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="ISBN is required."
        )

    # Example: Using OpenLibrary API (replace with your preferred API)
    # Note: You might need to sign up for an API key for some services.
    api_url = f"https://openlibrary.org/isbn/{isbn}.json"
    try:
        response = requests.get(api_url)
        response.raise_for_status()  # Raises an HTTPError for bad responses (4XX or 5XX)
        data = response.json()

        # Extract desired fields - this will vary greatly depending on the API
        # This is a simplified example.
        title = data.get('title', 'N/A')
        authors = [author['key'] for author in data.get('authors', [])] # Gets author keys
        publishers = data.get('publishers', ['N/A'])
        # Genre is often not directly available or is complex; placeholder
        genre = data.get('subjects', ['N/A']) # Subjects can be a proxy for genre

        return {
            "title": title,
            "authors": authors, # Or fetch author names if API allows easily
            "publisher": publishers[0] if publishers else 'N/A',
            "genre": genre[0] if genre else 'N/A', # Simplified
        }
    except requests.exceptions.RequestException as e:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAVAILABLE,
            message=f"Failed to fetch book details: {e}"
        )
    except KeyError as e:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=f"Error processing book details from API: missing key {e}"
        )


# TODO: Implement updateAggregates. This is complex and depends on specific aggregation needs.
# It could involve Firestore transactions or batched writes for efficiency.
# A cron job (Cloud Scheduler) might be better for periodic updates rather than real-time.
# For real-time, consider Firestore triggers or writing to a temporary collection
# that a separate function processes.
# Using an extension like "Distributed Counter" might be relevant for simple counts.
def update_aggregates(buffer):
    """
    Updates aggregate counts (e.g., apartment counts, genre counts).
    Now implemented based on the buffer data from catalog processing.
    """
    try:
        print(f"Updating aggregates with buffer: {buffer}")
        
        books_added = buffer.get("books_added", 0)
        volunteer_uid = buffer.get("volunteer_uid")
        donor_id = buffer.get("donor_id")
        donation_id = buffer.get("donation_id")
        
        # Update global counters
        aggregates_ref = db.collection('aggregates').document('stats')
        aggregates_doc = aggregates_ref.get()
        
        if aggregates_doc.exists:
            current_stats = aggregates_doc.to_dict()
        else:
            current_stats = {
                "total_books": 0,
                "total_donations": 0,
                "total_volunteers": 0,
                "total_donors": 0
            }
        
        # Update counters
        current_stats["total_books"] = current_stats.get("total_books", 0) + books_added
        current_stats["total_donations"] = current_stats.get("total_donations", 0) + 1
        current_stats["last_updated"] = firestore.SERVER_TIMESTAMP
        
        # Update volunteer count if new volunteer
        if volunteer_uid:
            volunteer_key = f"volunteer_{volunteer_uid}"
            if volunteer_key not in current_stats:
                current_stats["total_volunteers"] = current_stats.get("total_volunteers", 0) + 1
                current_stats[volunteer_key] = True
        
        # Update donor count if new donor
        if donor_id and donor_id != "anonymous":
            donor_key = f"donor_{donor_id}"
            if donor_key not in current_stats:
                current_stats["total_donors"] = current_stats.get("total_donors", 0) + 1
                current_stats[donor_key] = True
        
        # Write back to Firestore
        aggregates_ref.set(current_stats, merge=True)
        
        log_event("aggregates_updated", {
            "books_added": books_added,
            "donation_id": donation_id,
            "new_totals": {
                "books": current_stats["total_books"],
                "donations": current_stats["total_donations"]
            }
        })
        
    except Exception as e:
        log_event("aggregates_update_error", {
            "error": str(e),
            "buffer": buffer
        })


def register_book_to_catalog(donor_id, isbns, volunteer_uid):
    """
    Registers a list of books (by ISBN) to the catalog and creates copy entries.
    """
    db = firestore.client()
    copies_registered_ids = []
    # aggregate_buffer = {} # Initialize buffer for aggregate updates

    if not volunteer_uid:
        raise ValueError("Volunteer UID is required to register books.")

    for isbn in isbns:
        # Fetch book details (title, author, etc.)
        # In a real scenario, you might call get_book_details or have this info passed
        try:
            book_details_data = get_book_details_internal(isbn) # internal call
        except Exception as e:
            print(f"Could not fetch details for ISBN {isbn}: {e}. Skipping this book.")
            continue


        # Create a new document in 'catalog' if it doesn't exist (or just use ISBN as ID)
        # For simplicity, let's assume ISBN can be the bookID or part of it.
        # If a separate auto-gen bookID is needed, that logic goes here.
        # book_ref = db.collection('catalog').document() # Auto-generated ID
        # book_id = book_ref.id
        # book_ref.set({"isbn": isbn, **book_details_data}) # Store basic book info

        # Create a new copy entry
        copy_ref = db.collection('copies').document()
        copy_id = copy_ref.id
        full_id = f"{isbn}_{copy_id}" # Example full ID, adjust as needed

        copy_data = {
            "fullId": full_id,
            "donorId": donor_id,
            "volunteerUid": volunteer_uid,
            "isbn": isbn,
            "registrationDate": firestore.SERVER_TIMESTAMP,
            **book_details_data # Add title, author etc. from get_book_details
        }
        copy_ref.set(copy_data)
        copies_registered_ids.append(full_id)

        # TODO: Update aggregates buffer
        # e.g., increment genre count for book_details_data['genre']
        # e.g., increment apartment count if donor_details included apartment info
        # update_aggregates_buffer(aggregate_buffer, book_details_data, donor_details)

    # update_aggregates(aggregate_buffer) # Call actual update function
    return copies_registered_ids

def get_book_details_internal(isbn):
    """Internal helper to fetch book details, not an exposed Cloud Function."""
    if not is_isbn(isbn):
        raise ValueError(f"Invalid ISBN format: {isbn}")
    
    # Clean ISBN for API call
    clean_isbn = isbn.replace('-', '').replace(' ', '')
    
    # Try OpenLibrary API first
    api_url = f"https://openlibrary.org/isbn/{clean_isbn}.json"
    try:
        response = requests.get(api_url, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        return {
            'title': data.get('title', 'Unknown Title'),
            'author': ', '.join([author.get('name', 'Unknown') for author in data.get('authors', [])]),
            'genre': data.get('subjects', ['Unknown'])[0] if data.get('subjects') else 'Unknown',
            'publisher': ', '.join(data.get('publishers', ['Unknown'])),
            'isbn': isbn,
            'cover_url': f"https://covers.openlibrary.org/b/isbn/{clean_isbn}-M.jpg"
        }
    except Exception as e:
        print(f"API call failed for ISBN {isbn}: {e}")
        
        # Fallback to mock data for testing
        if isbn == "9780000000001":
            return {
                "title": "The Great Example Book",
                "author": "Author One, Author Two",
                "publisher": "Example Publisher",
                "genre": "Fiction",
                "isbn": isbn
            }
        elif isbn == "9780000000002":
            return {
                "title": "Another Fine Book",
                "author": "Author Three",
                "publisher": "Another Publisher",
                "genre": "Non-Fiction",
                "isbn": isbn
            }
        else:
            # Return unknown book details rather than raising error
            return {
                "title": "Unknown Title",
                "author": "Unknown Author", 
                "publisher": "Unknown Publisher",
                "genre": "Unknown",
                "isbn": isbn
            }


def generate_receipt(volunteer_uid, donor_id, copies_details, donor_details):
    """
    Generates a receipt string or object.
    (Placeholder - customize as needed)
    """
    # Fetch more details if needed (e.g., volunteer name, donor name)
    db = firestore.client()
    volunteer_name = "Volunteer" # Placeholder
    if volunteer_uid:
        volunteer_doc = db.collection('volunteers').document(volunteer_uid).get()
        if volunteer_doc.exists:
            volunteer_name = volunteer_doc.to_dict().get('name', volunteer_uid)


    donor_name = donor_details.get('name', 'Anonymous Donor')
    donor_phone = donor_details.get('phoneNumber', 'N/A')


    receipt_lines = [
        f"--- Book Donation Receipt ---",
        f"Date: {firestore.SERVER_TIMESTAMP}", # Will be converted by Firestore
        f"Volunteer: {volunteer_name} ({volunteer_uid})",
        f"Donor: {donor_name} (ID: {donor_id}, Phone: {donor_phone})",
        f"--- Books Donated ---"
    ]
    for i, copy_info in enumerate(copies_details):
        # Assuming copies_details is a list of dicts with book info
        title = copy_info.get('title', 'N/A')
        isbn = copy_info.get('isbn', 'N/A')
        receipt_lines.append(f"{i+1}. {title} (ISBN: {isbn}) - Copy ID: {copy_info.get('fullId', 'N/A')}")

    receipt_lines.append("--- Thank you for your donation! ---")
    return "\n".join(receipt_lines)


# TODO: Implement email sending. This typically requires a third-party email service
# like SendGrid, Mailgun, or using Firebase Extensions for email.
def send_email(to_email, subject, body):
    """
    Placeholder for sending an email.
    """
    if not to_email:
        print("No email address provided for donor, skipping email.")
        return

    print(f"Simulating sending email to: {to_email}")
    print(f"Subject: {subject}")
    print(f"Body:\n{body}")
    # In a real implementation:
    # msg = EmailMessage()
    # msg.set_content(body)
    # msg['Subject'] = subject
    # msg['From'] = YOUR_SENDING_EMAIL_ADDRESS
    # msg['To'] = to_email
    # smtp_server.send_message(msg)
    pass

def log_event(event_name, details):
    """
    Logs an event to Firestore or Cloud Logging.
    """
    print(f"Logging event: {event_name}, Details: {details}")
    db = firestore.client()
    db.collection('logs').add({
        "event": event_name,
        "timestamp": firestore.SERVER_TIMESTAMP,
        "details": details
    })


@https_fn.on_call()
def add_book_to_catalog(req: https_fn.CallableRequest):
    """
    Main function to add books to the catalog.
    Orchestrates donor handling, book registration, receipt generation, and notifications.
    """
    volunteer_uid = req.auth.uid if req.auth else None
    if not volunteer_uid:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required. Ensure you are logged in."
        )

    # 1. Validate request is from a volunteer
    db = firestore.client()
    volunteer_ref = db.collection('volunteers').document(volunteer_uid)
    if not volunteer_ref.get().exists:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.PERMISSION_DENIED,
            message="User is not a registered volunteer."
        )

    data = req.data
    donor_details_req = data.get('donorDetails')
    isbns = data.get('isbns')

    if not donor_details_req or not isbns:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Missing donorDetails or isbns in the request."
        )
    if not isinstance(isbns, list) or not all(isinstance(isbn, str) for isbn in isbns):
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="isbns must be a list of strings."
        )

    donor_id = None
    phone_number = donor_details_req.get('phoneNumber')

    # 2. Check if donor exists by phone number, or add new donor
    if phone_number:
        # Check if donor exists
        donors_ref = db.collection('donors')
        query = donors_ref.where('phoneNumber', '==', phone_number).limit(1)
        existing_donors = list(query.stream()) # list() to execute
        if existing_donors:
            donor_id = existing_donors[0].id
            # Optionally, update donor details if new ones are provided
            # existing_donors[0].reference.update(donor_details_req)
            print(f"Existing donor found: {donor_id} for phone: {phone_number}")
        else:
            # Add new donor if phone number provided but not found
            print(f"New donor with phone number: {phone_number}. Adding...")
            donor_id = add_donor_details(donor_details_req)
            print(f"New donor added with ID: {donor_id}")
    else:
        # Add new donor (anonymous or no phone provided)
        print("No phone number provided or new donor. Adding...")
        donor_id = add_donor_details(donor_details_req) # Will generate ID if phone is missing
        print(f"New donor added with ID: {donor_id}")


    # 3. Register books to catalog
    # We need full book details for the receipt, so let's get them first.
    registered_copies_full_details = []
    for isbn_item in isbns: # Assuming isbns is a list of ISBN strings
        try:
            # In a real scenario, get_book_details_internal would fetch from an API
            # or a 'catalog' collection if books are pre-registered there.
            # For now, it uses mock data.
            book_meta = get_book_details_internal(isbn_item)

            # Create a new copy entry
            copy_ref = db.collection('copies').document() # Auto-generated ID for the copy
            copy_id = copy_ref.id
            full_id = f"{isbn_item}_{copy_id}" # Construct a unique ID for the copy

            copy_data = {
                "fullId": full_id,
                "donorId": donor_id,
                "volunteerUid": volunteer_uid,
                "isbn": isbn_item,
                "registrationDate": firestore.SERVER_TIMESTAMP,
                **book_meta # Add title, author, genre etc.
            }
            copy_ref.set(copy_data)
            registered_copies_full_details.append(copy_data) # Store for receipt
            print(f"Registered copy: {full_id} for ISBN {isbn_item}")

        except Exception as e:
            log_event("book_registration_error", {"isbn": isbn_item, "error": str(e)})
            print(f"Error registering ISBN {isbn_item}: {e}. Skipping.")
            # Decide if one error should stop the whole process or just skip the book
            # For now, it skips.

    if not registered_copies_full_details:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.ABORTED,
            message="No books were successfully registered."
        )

    # 4. Generate Receipt
    # The `donor_details_req` is what the client sent.
    # If we fetched an existing donor, we might want to use their stored details for the receipt.
    # For simplicity, using the request's donor details for now.
    receipt = generate_receipt(volunteer_uid, donor_id, registered_copies_full_details, donor_details_req)

    # 5. Email Receipt
    donor_email = donor_details_req.get('email')
    if donor_email:
        send_email(
            to_email=donor_email,
            subject="Your Book Donation Receipt from TeamBooks",
            body=receipt
        )
    else:
        print("No donor email provided, skipping email notification.")

    # 6. Log event
    log_event(
        "add_book_to_catalog_success",
        {
            "volunteerUid": volunteer_uid,
            "donorId": donor_id,
            "booksRegisteredCount": len(registered_copies_full_details),
            "isbns": [copy['isbn'] for copy in registered_copies_full_details]
        }
    )

    return {"receipt": receipt, "donorId": donor_id, "registeredBookCount": len(registered_copies_full_details)}

# Example of how get_book_details_internal might be used if it were more complex
# and needed to be separate from the main on_call get_book_details
# def get_book_details_internal(isbn: str) -> dict:
#     # This would contain the actual logic for fetching from a specific API
#     # For example, using 'requests' library
#     # This is kept simple here as the main get_book_details already shows an example
#     if isbn == "1234567890123": # Dummy ISBN
#         return {"title": "The Great Book", "author": "John Doe", "publisher": "Pub Co", "genre": "Fiction"}
#     else:
#         return {"title": "Unknown Book", "author": "N/A", "publisher": "N/A", "genre": "N/A"}

# To deploy these functions:
# Ensure you have firebase-tools installed and configured.
# Run `firebase deploy --only functions` from your project's root directory (where firebase.json is).