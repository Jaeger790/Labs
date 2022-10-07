function rangeOfNumbers(startNum, endNum) {
  if (endNum - startNum === 0){
    return [startNum];
  }else{
    const arr = rangeOfNumbers(startNum, endNum-1);
    arr.push(endNum);
    return arr;
  }
  
};