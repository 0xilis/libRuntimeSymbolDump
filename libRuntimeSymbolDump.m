#import <Foundation/Foundation.h>

//thank you to https://gist.github.com/domnikl/af00cc154e3da1c5d965
void hexDumpByNSLog(const char *desc, void *addr, int len) {
 int i;
 unsigned char *pc = (unsigned char*)addr;
 NSString* outputLog = @"(libRSD)";

 // Output description if given.
 if (desc != NULL) {
  outputLog = [outputLog stringByAppendingString:[NSString stringWithFormat:@"%s:\n", desc]];
 }

 // Process every byte in the data.
 for (i = 0; i < len; i++) {
  // Multiple of 16 means new line (with line offset).
  if ((i % 16) == 0) {
   // Just don't print ASCII for the zeroth line.
   if (i != 0) {
    outputLog = [outputLog stringByAppendingString:[NSString stringWithFormat:@"\n"]];
   }
  }
  // Now the hex code for the specific character.
  outputLog = [outputLog stringByAppendingString:[NSString stringWithFormat:@" %02x", pc[i]]];
 }
 NSLog(@"%@",outputLog);
}

void hexDumpSymbolFromCallStackSymbols(NSString *symbolToFind) {
 NSArray<NSString *> * callstack = [NSThread callStackSymbols];

 for (NSString* symbolString in callstack) {
  //NSCaseInsensitiveSearch / NSBackwardsSearch
  NSRange range = [symbolString rangeOfString:@"0x" options:NSBackwardsSearch];
  NSString* temp1 = [symbolString substringFromIndex:range.location];
  NSRange range2 = [temp1 rangeOfString:@" " options:NSCaseInsensitiveSearch];
  NSString* symbolJmpAddr = [temp1 substringToIndex:range2.location]; //symbol addr, well not addr of symbol but where the jmp in the symbol was

  //symbol name
  NSString *temp3 = [temp1 substringFromIndex:(range2.location + 1)]; // +1 to get rid of nasty extra space
  NSRange range3 = [temp3 rangeOfString:@" + " options:NSBackwardsSearch];
  NSString *symbolName = [temp3 substringToIndex:range3.location];

  if ([symbolName isEqualToString:symbolToFind]) {
   //symbol is symbolToFind

   //the position / offset of where the jmp is in the symbol; (symboladdr + jmp offset = where it jmped to new function)
   long jmpOffset = [[temp3 substringFromIndex:(range3.location + 3)] integerValue];
   NSLog(@"(libRSD)symbol jmp offset: %ld", jmpOffset);

   //calculate the pointer to the actual symbol
   unsigned long long jmpAddress;
   NSScanner* scanner = [NSScanner scannerWithString:symbolJmpAddr];
   [scanner scanHexLongLong:&jmpAddress];
   //result is our ptr to jmp address, substract offset from it to get symbol address
   void *fptr = (void *)(jmpAddress - jmpOffset);
   NSLog(@"(libRSD)pointer to symbol: %p",fptr);
   NSLog(@"(libRSD)jmpAddress: %lld", jmpAddress);
   NSLog(@"(libRSD)jmpOffset: %@", symbolSize);
   NSLog(@"(libRSD)symbolJmpAddr: %@", symbolJmpAddr);

   if (fptr != NULL) {
    hexDumpByNSLog([[NSString stringWithFormat:@"%@ until jmp",symbolName]cStringUsingEncoding:NSUTF8StringEncoding], fptr, jmpOffset);
   } else {
    NSLog(@"(libRSD)fptr is NULL!! (wtf?)");
   }
  }
 }
 NSLog(@"(libRSD)ran hexDumpSymbolFromCallStackSymbols()\n");
}

void* findSymbolPtrFromCallStackSymbols(NSString *symbolToFind) {
 NSArray<NSString *> * callstack = [NSThread callStackSymbols];

 for (NSString* symbolString in callstack) {
  //NSCaseInsensitiveSearch / NSBackwardsSearch
  NSRange range = [symbolString rangeOfString:@"0x" options:NSBackwardsSearch];
  NSString* temp1 = [symbolString substringFromIndex:range.location];
  NSRange range2 = [temp1 rangeOfString:@" " options:NSCaseInsensitiveSearch];
  NSString* symbolJmpAddr = [temp1 substringToIndex:range2.location]; //symbol addr, well not addr of symbol but where the jmp in the symbol was

  //symbol name
  NSString *temp3 = [temp1 substringFromIndex:(range2.location + 1)]; // +1 to get rid of nasty extra space
  NSRange range3 = [temp3 rangeOfString:@" + " options:NSBackwardsSearch];
  NSString *symbolName = [temp3 substringToIndex:range3.location];

  if ([symbolName isEqualToString:symbolToFind]) {
   //symbol is symbolToFind

   //the position / offset of where the jmp is in the symbol; (symboladdr + jmp offset = where it jmped to new function)
   long jmpOffset = [[temp3 substringFromIndex:(range3.location + 3)] integerValue];
   NSLog(@"(libRSD)symbol jmp offset: %ld", jmpOffset);

   //calculate the pointer to the actual symbol
   unsigned long long jmpAddress;
   NSScanner* scanner = [NSScanner scannerWithString:symbolJmpAddr];
   [scanner scanHexLongLong:&jmpAddress];
   //result is our ptr to jmp address, substract offset from it to get symbol address
   void *fptr = (void *)(jmpAddress - jmpOffset);
   return fptr;
  }
 }
 NSLog(@"(libRSD)ran findSymbolPtrFromCallStackSymbols()\n");
 return -1;
}
