void hexDumpByNSLog(const char *desc, void *addr, int len);
void hexDumpSymbolFromCallStackSymbols(NSString *symbolToFind);
void* findSymbolPtrFromCallStackSymbols(NSString *symbolToFind);
