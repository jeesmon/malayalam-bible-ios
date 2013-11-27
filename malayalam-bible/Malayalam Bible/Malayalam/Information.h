//
//  Information.h
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Information : UIViewController {
    UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end


/**** Update queries on database +20131127
update verses set verse_text='ഒരുത്തൻ നേർച്ചനിവൃത്തിക്കായിട്ടോ സ്വമേധാദാനമായിട്ടൊ  യഹോവെക്കു മാടുകളിൽനിന്നാകട്ടെ ആടുകളിൽനിന്നാകട്ടെ ഒന്നിനെ സാമാധാനയാഗമായിട്ടു അര്‍പ്പിക്കുമ്പോള്‍ അതു പ്രസാദമാകുവാന്തക്കവണ്ണം ഊനമില്ലത്തതായിരിക്കേണം; അതിന്നു ഒരു കുറവും ഉണ്ടായിരിക്കരുതു.' where book_id=3 and chapter_id=22 and verse_id=21;
update verses set verse_text='അപ്പോൾ മറിയ പറഞ്ഞതു: “എന്റെ ഉള്ളം കർത്താവിനെ മഹിമപ്പെടുത്തുന്നു;' where book_id=42 and chapter_id=1 and verse_id=46;
update verses set verse_text='കർത്താവിന്റെ പ്രസാദവർഷം പ്രസംഗിപ്പാനും എന്നെ അയച്ചിരിക്കുന്നു” എന്നു എഴുതിയിരിക്കുന്ന സ്ഥലം കണ്ടു.' where book_id=42 and chapter_id=4 and verse_id=19;

 update verses set verse_text='ആദിയിൽ ദൈവം ആകാശവും ഭൂമിയും സൃഷ്ടിച്ചു.' where book_id=1 and chapter_id=1 and verse_id=1;
 update verses set verse_text='വരുന്നവരും പോകുന്നവരും വളരെ ആയിരുന്നതിനാൽ അവർക്കു ഭക്ഷിപ്പാൻ പോലും സമയം ഇല്ലായ്കകൊണ്ടു അവൻ  അവരോടു: “നിങ്ങൾ ഒരു ഏകാന്തസ്ഥലത്തു വേറിട്ടുവന്നു അല്പം ആശ്വസിച്ചുകൊൾവിൻ” എന്നു പറഞ്ഞു.' where book_id=41 and chapter_id=6 and verse_id=31;
 update verses set verse_text='അങ്ങനെ അവർ യേശുവിനോടു: ഞങ്ങൾക്കു അറിഞ്ഞുകൂടാ എന്നു ഉത്തരം പറഞ്ഞു. "എന്നാൽ ഞാനും ഇതു ഇന്ന അധികാരംകൊണ്ടു ചെയ്യുന്നു എന്നു നിങ്ങളോടു പറയുന്നില്ല"  എന്നു യേശു അവരോടു പറഞ്ഞു.' where book_id=41 and chapter_id=11 and verse_id=33;

****/