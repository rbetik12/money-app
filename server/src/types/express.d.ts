import { Profile } from 'passport-google-oauth20';

declare global {
  namespace Express {
    interface User extends Profile {}
  }
}

declare global {
    namespace Express {
      interface Request {
        user?: Profile;
      }
    }
  }
