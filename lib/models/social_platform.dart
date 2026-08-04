enum SocialPlatform {
  youtube,
  instagram,
  facebook,
  threads,
  reddit,
  linkedin,
  pinterest,
  x,
  snapchat,
  unknown,
}

extension SocialPlatformExtension on SocialPlatform {
  String get value {
    switch (this) {
      case SocialPlatform.youtube:  
        return 'youtube';
        
      case SocialPlatform.instagram:  
        return 'instagram';
        
      case SocialPlatform.facebook:  
        return 'facebook';
        
      case SocialPlatform.threads:  
        return 'threads';
        
      case SocialPlatform.reddit:  
        return 'reddit';
        
      case SocialPlatform.linkedin:  
        return 'linkedin';
        
      case SocialPlatform.pinterest:  
        return 'pinterest';
        
      case SocialPlatform.x:  
        return 'x';
        
      case SocialPlatform.snapchat:  
        return 'snapchat';
        
      case SocialPlatform.unknown:  
        return 'unoknown';
    }
  }

  static SocialPlatform fromString(String value) {
    switch (value.toLowerCase()) {
      case 'youtube': 
        return SocialPlatform.youtube;
        
      case 'instagram': 
        return SocialPlatform.instagram;
        
      case 'facebook': 
        return SocialPlatform.facebook;
        
      case 'threads': 
        return SocialPlatform.threads;
        
      case 'reddit': 
        return SocialPlatform.reddit;
        
      case 'linkedin': 
        return SocialPlatform.linkedin;
        
      case 'pinterest': 
        return SocialPlatform.pinterest;
        
      case 'x': 
        return SocialPlatform.x;
        
      case 'snapchat': 
        return SocialPlatform.snapchat;
        
      default: 
        return SocialPlatform.unknown;
    }
  }
}