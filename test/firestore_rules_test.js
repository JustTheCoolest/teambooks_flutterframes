const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { readFileSync } = require('fs');
const path = require('path');

let testEnv;

describe('Firestore Rules Tests', () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'test-project',
      firestore: {
        rules: readFileSync(path.join(__dirname, '../firestore.rules'), 'utf8'),
        host: 'localhost',
        port: 8088
      }
    });
  });

  after(async () => {
    await testEnv.cleanup();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    
    // Set up a test volunteer in the Volunteers collection
    await testEnv.withSecurityRulesDisabled(context => {
      return context.firestore().collection('Volunteers').doc('volunteer-uid-123').set({
        name: 'Test Volunteer',
        email: 'volunteer@test.com'
      });
    });
  });

  describe('CatalogQueue Collection', () => {
    const validDonation = {
      volunteerUid: 'volunteer-uid-123',
      isbns: ['9781234567890', '9780987654321'],
      wasOffline: false,
      editDonorIntent: false,
      timestamp: new Date()
    };

    describe('Valid Cases', () => {
      it('should allow creating a donation with all required fields', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertSucceeds(
          db.collection('CatalogQueue').doc('donation-1').set(validDonation)
        );
      });

      it('should allow donation with donorId when user is authenticated volunteer', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertSucceeds(
          db.collection('CatalogQueue').doc('donation-2').set({
            ...validDonation,
            donorId: 'donor-123'
          })
        );
      });

      it('should allow donorDetails when wasOffline is true', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertSucceeds(
          db.collection('CatalogQueue').doc('donation-3').set({
            ...validDonation,
            wasOffline: true,
            donorDetails: {
              name: 'John Doe',
              phoneNumber: '+1234567890',
              email: 'john@example.com',
              'apartment/company': 'Apt 123'
            }
          })
        );
      });

      it('should allow donorDetails when editDonorIntent is true', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertSucceeds(
          db.collection('CatalogQueue').doc('donation-4').set({
            ...validDonation,
            editDonorIntent: true,
            donorDetails: {
              name: 'Jane Smith',
              phoneNumber: '+1987654321',
              email: 'jane@example.com',
              'apartment/company': 'Company ABC'
            }
          })
        );
      });

      it('should allow donorDetails with donorId when editDonorIntent is true', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertSucceeds(
          db.collection('CatalogQueue').doc('donation-5').set({
            ...validDonation,
            donorId: 'donor-456',
            editDonorIntent: true,
            donorDetails: {
              name: 'Bob Wilson',
              phoneNumber: '+1122334455',
              email: 'bob@example.com',
              'apartment/company': 'Suite 456'
            }
          })
        );
      });
    });

    describe('Authentication and Authorization Failures', () => {
      it('should deny unauthenticated requests', async () => {
        const db = testEnv.unauthenticatedContext().firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-1').set(validDonation)
        );
      });

      it('should deny when volunteerUid does not match authenticated user', async () => {
        const db = testEnv.authenticatedContext('different-uid').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-2').set(validDonation)
        );
      });

      it('should deny when user is not in Volunteers collection', async () => {
        const db = testEnv.authenticatedContext('non-volunteer-uid').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-3').set({
            ...validDonation,
            volunteerUid: 'non-volunteer-uid'
          })
        );
      });
    });

    describe('Field Validation Failures', () => {
      it('should deny when required fields are missing', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        const incompleteData = { ...validDonation };
        delete incompleteData.isbns;
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-4').set(incompleteData)
        );
      });

      it('should deny when extra fields are present', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-5').set({
            ...validDonation,
            extraField: 'not allowed'
          })
        );
      });

      it('should deny when isbns list is empty', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-6').set({
            ...validDonation,
            isbns: []
          })
        );
      });

      it('should deny when data types are incorrect', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-7').set({
            ...validDonation,
            wasOffline: 'not-a-boolean'
          })
        );
      });

      it('should deny when donorDetails is missing required fields', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-8').set({
            ...validDonation,
            editDonorIntent: true,
            donorDetails: {
              name: 'Incomplete Donor'
              // missing other required fields
            }
          })
        );
      });
    });

    describe('Business Logic Failures', () => {
      it('should deny donorDetails when editDonorIntent is false and wasOffline is false', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-9').set({
            ...validDonation,
            editDonorIntent: false,
            wasOffline: false,
            donorDetails: {
              name: 'Should Not Work',
              phoneNumber: '+1234567890',
              email: 'shouldnotwork@example.com',
              'apartment/company': 'Failed Apt'
            }
          })
        );
      });

      it('should deny donorDetails with donorId when editDonorIntent is false', async () => {
        const db = testEnv.authenticatedContext('volunteer-uid-123').firestore();
        
        await assertFails(
          db.collection('CatalogQueue').doc('donation-fail-10').set({
            ...validDonation,
            donorId: 'donor-789',
            editDonorIntent: false,
            donorDetails: {
              name: 'Should Not Work',
              phoneNumber: '+1234567890',
              email: 'shouldnotwork@example.com',
              'apartment/company': 'Failed Apt'
            }
          })
        );
      });
    });
  });

  describe('TestCollection', () => {
    it('should allow writing when items array contains only integers', async () => {
      const db = testEnv.authenticatedContext('any-user').firestore();
      
      await assertSucceeds(
        db.collection('TestCollection').doc('test-1').set({
          items: [1, 2, 3, 4, 5]
        })
      );
    });

    it('should deny writing when items array contains non-integers', async () => {
      const db = testEnv.authenticatedContext('any-user').firestore();
      
      await assertFails(
        db.collection('TestCollection').doc('test-2').set({
          items: [1, 'not-an-int', 3]
        })
      );
    });
  });
});
