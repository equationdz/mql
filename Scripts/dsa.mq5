//+------------------------------------------------------------------+ 
//| ArrayToHex                                                       | 
//+------------------------------------------------------------------+ 
string ArrayToHex(uchar &arr[],int count=-1) 
  { 
   string res=""; 
//--- 检查 
   if(count<0 || count>ArraySize(arr)) 
      count=ArraySize(arr); 
//--- 转换到 HEX 字符串 
   for(int i=0; i<count; i++) 
      res+=StringFormat("%.2X",arr[i]); 
//--- 
   return(res); 
  } 
//+------------------------------------------------------------------+ 
//| 脚本程序起始函数                                                   | 
//+------------------------------------------------------------------+ 
void OnStart() 
  { 
   string text="555321"; 
   string keystr="ABCDEFG"; 
   uchar src[],dst[],key[]; 
//--- 准备密钥 
   StringToCharArray(keystr,key); 
//--- 复制文本到源数组src[] 
   StringToCharArray(text,src); 
//--- 打印初始数据 
   PrintFormat("Initial data: size=%d, string='%s'",ArraySize(src),CharArrayToString(src)); 
//--- 用key[]的DES56位密钥加密DES src[] 
   int res=CryptEncode(CRYPT_DES,src,key,dst); 
//--- 检查错误 
   if(res>0) 
     { 
      //--- 打印加密数据 
      PrintFormat("Encoded data: size=%d %s",res,ArrayToHex(dst)); 
      //--- 解码 dst[] 到 src[] 
      res=CryptDecode(CRYPT_DES,dst,key,src); 
      //--- 检查错误     
      if(res>0) 
        { 
         //--- 打印解码数据 
         PrintFormat("Decoded data: size=%d, string='%s'",ArraySize(src),CharArrayToString(src)); 
        } 
      else 
         Print("Error in CryptDecode. Error code=",GetLastError()); 
     } 
   else 
      Print("Error in CryptEncode. Error code=",GetLastError()); 
  }
 

