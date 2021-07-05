public class CustomIterator 
  implements Iterator<sObject>{ 
 
   private List<sObject> accs;
   private Integer currentIndex;
 
   public CustomIterator(List<sObject> accs){
       this.accs = accs;
       this.currentIndex = 0;
   }
 
   public boolean hasNext(){ 
       return currentIndex < accs.size() - 1;
   }    
 
   public sObject next(){
       if(hasNext()) {
           currentIndex++;
           return accs[currentIndex];
       } else {
           throw new NoSuchElementException();
       }
   } 
}