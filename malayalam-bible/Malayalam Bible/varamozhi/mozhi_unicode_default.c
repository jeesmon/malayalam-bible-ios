#include "mal-type.h"
char* mal_parse(char* mal_in_text, long flags);
static MapTable map =  {
	{"0", "", "", "", "", "" },
	{"1", "ഃ", "", "", "", "" },
	{"2", " ", "", "", "", "" },
	{"3", "\t", "", "", "", "" },
	{"4", "!", "", "", "", "" },
	{"5", "%", "", "", "", "" },
	{"6", "*", "", "", "", "" },
	{"7", "+", "", "", "", "" },
	{"8", "/", "", "", "", "" },
	{"9", ".", "", "", "", "" },
	{"10", ";", "", "", "", "" },
	{"11", ":", "", "", "", "" },
	{"12", "<", "", "", "", "" },
	{"13", "=", "", "", "", "" },
	{"14", ">", "", "", "", "" },
	{"15", ",", "", "", "", "" },
	{"16", "(", "", "", "", "" },
	{"17", ")", "", "", "", "" },
	{"18", "?", "", "", "", "" },
	{"19", "[", "", "", "", "" },
	{"20", "]", "", "", "", "" },
	{"21", "-", "", "", "", "" },
	{"22", "0", "", "", "", "" },
	{"23", "1", "", "", "", "" },
	{"24", "2", "", "", "", "" },
	{"25", "3", "", "", "", "" },
	{"26", "4", "", "", "", "" },
	{"27", "5", "", "", "", "" },
	{"28", "6", "", "", "", "" },
	{"29", "7", "", "", "", "" },
	{"30", "8", "", "", "", "" },
	{"31", "9", "", "", "", "" },
	{"32", "൦", "", "", "", "" },
	{"33", "൧", "", "", "", "" },
	{"34", "൨", "", "", "", "" },
	{"35", "൩", "", "", "", "" },
	{"36", "൪", "", "", "", "" },
	{"37", "൫", "", "", "", "" },
	{"38", "൬", "", "", "", "" },
	{"39", "൭", "", "", "", "" },
	{"40", "൮", "", "", "", "" },
	{"41", "൯", "", "", "", "" },
	{"42", "൰", "", "", "", "" },
	{"43", "൱", "", "", "", "" },
	{"44", "൲", "", "", "", "" },
	{"45", "൳", "", "", "", "" },
	{"46", "൴", "", "", "", "" },
	{"47", "൵", "", "", "", "" },
	{"48", "ൿ", "", "", "", "" },
	{"49", "൹", "", "", "", "" },
	{"50", "അ", "", "", "", "" },
	{"51", "ആ", "", "ാ", "ാ", "" },
	{"52", "ഇ", "", "ി", "ീ", "" },
	{"53", "ഈ", "", "ീ", "ീ", "" },
	{"54", "ഉ", "", "ു", "ൂ", "" },
	{"55", "ഊ", "", "ൂ", "ൂ", "" },
	{"56", "ഋ", "", "ൃ", "", "" },
	{"57", "ൠ", "", "ൄ", "", "" },
	{"58", "ഌ", "", "ൢ", "", "" },
	{"59", "ൡ", "", "്ൡ", "", "" },
	{"60", "എ", "", "െ", "ീ", "" },
	{"61", "ഏ", "", "േ", "", "" },
	{"62", "ഐ", "", "ൈ", "", "" },
	{"63", "ഒ", "", "ൊ", "ൂ", "" },
	{"64", "ഓ", "", "ോ", "ാ", "" },
	{"65", "ഔ", "", "ൗ", "", "" },
	{"66", "ഽ", "", "ഽ", "", "" },
	{"67", "ാ‍", "", "", "", "" },
	{"68", "ി‍", "", "", "", "" },
	{"69", "ീ‍", "", "", "", "" },
	{"70", "ു‍", "", "", "", "" },
	{"71", "ൂ‍", "", "", "", "" },
	{"72", "ൃ‍", "", "", "", "" },
	{"73", "െ‍", "", "", "", "" },
	{"74", "േ‍", "", "", "", "" },
	{"75", "ൌ‍", "", "", "", "" },
	{"76", "്", "", "്‌", "്", "" },
	{"77", "", "", "", "", "" },
	{"78", "ക", "", "", "ൿ", "" },
	{"79", "ഖ", "", "", "", "" },
	{"80", "ഘ", "", "", "", "" },
	{"81", "ങ", "", "", "", "" },
	{"82", "ച", "", "", "", "" },
	{"83", "ഛ", "", "", "", "" },
	{"84", "ജ", "", "", "", "" },
	{"85", "ഝ", "", "", "", "" },
	{"86", "ഞ", "", "", "", "" },
	{"87", "പ", "", "", "", "" },
	{"88", "ഫ", "", "", "", "" },
	{"89", "ബ", "", "", "", "" },
	{"90", "ഭ", "", "", "", "" },
	{"91", "ഷ", "", "", "", "" },
	{"92", "ഹ", "", "", "", "" },
	{"93", "റ്റ", "", "", "", "" },
	{"94", "്യ‍", "", "", "", "" },
	{"95", "്ര‍", "", "", "", "" },
	{"96", "്ല‍", "", "", "", "" },
	{"97", "്വ‍", "", "", "", "" },
	{"98", "ശ", "", "", "", "" },
	{"99", "സ", "", "", "", "" },
	{"100", "ഗ", "", "", "", "" },
	{"101", "ട", "", "", "", "" },
	{"102", "ഠ", "", "", "", "" },
	{"103", "ഢ", "", "", "", "" },
	{"104", "ഡ", "", "", "", "" },
	{"105", "ണ", "", "", "ൺ", "" },
	{"106", "ത", "", "", "", "" },
	{"107", "ഥ", "", "", "", "" },
	{"108", "ദ", "", "", "", "" },
	{"109", "ധ", "", "", "", "" },
	{"110", "ന", "", "", "ൻ", "" },
	{"111", "യ", "", "", "", "" },
	{"112", "ഴ", "", "", "", "" },
	{"113", "മ", "", "", "ം", "" },
	{"114", "ള", "", "്ല", "ൾ", "" },
	{"115", "ല", "", "്ല", "ൽ", "" },
	{"116", "റ", "", "്ര", "ർ", "" },
	{"117", "ര", "", "്ര", "ർ", "" },
	{"118", "വ", "", "", "", "" },
	{"119", "ന്റ", "", "", "", "" },
	{"120", "ന്മ", "", "", "", "" },
	{"121", "ണ്മ", "", "", "", "" },
	{"122", "മ്പ", "", "", "", "" },
	{"123", "ള്ള", "", "", "", "" },
	{"124", "യ്‌വ", "", "", "", "" },
	{"125", "യ്‌ല", "", "", "", "" },
	{"126", "യ്‌ര", "", "", "", "" },
				  { "","", "", "", ""}
				};

extern Private                 private;

extern int                     mozhi_unicodelex(void);
extern struct yy_buffer_state* mozhi_unicode_scan_bytes();
extern void                    mozhi_unicode_switch_to_buffer();
extern void                    mozhi_unicode_delete_buffer();

extern int                     macro_mozhi_unicodelex(void);
extern struct yy_buffer_state* macro_mozhi_unicode_scan_bytes();
extern void                    macro_mozhi_unicode_switch_to_buffer();
extern void                    macro_mozhi_unicode_delete_buffer();

char *mozhi_unicode_parse(char *str, long flags)
{
    
    private.map                 = &map;
    private.samindex            = 76;

    private.yylex               = mozhi_unicodelex;
    private.yy_scan_bytes       = mozhi_unicode_scan_bytes;
    private.yy_switch_to_buffer = mozhi_unicode_switch_to_buffer;
    private.yy_delete_buffer    = mozhi_unicode_delete_buffer;

    private.macrolex               = macro_mozhi_unicodelex;
    private.macro_scan_bytes       = macro_mozhi_unicode_scan_bytes;
    private.macro_switch_to_buffer = macro_mozhi_unicode_switch_to_buffer;
    private.macro_delete_buffer    = macro_mozhi_unicode_delete_buffer;

    return mal_parse(str, flags);
}

