class MegaStack[T]  private (elems: List[T]) (implicit num: Numeric[T]) {
  private val elements: List[T] = elems

  private val avg: Option[Double] = if (num == null) None else Some(num.toDouble(elements.sum) / elements.length)

  def push(x: T): MegaStack[T] = new MegaStack[T](x :: elements)

  def peek: T = elements.head

  def pop: MegaStack[T] = new MegaStack[T](elements.tail)

  def empty: Boolean = elements == Nil
  
  override def toString: String = this.elements.toString()

  def this() (implicit num: Numeric[T] = null) = this(List[T]())

  def average() : Double = if (avg == None) throw new IllegalArgumentException else avg.get
}


object Main extends App {
  println("Test 1: ")
  var stack1_empty = new MegaStack[Int]()
  println(stack1_empty.empty)
  val stack1_hasOne = stack1_empty.push(1)
  val stack1_hasTwo = stack1_hasOne.push(2)
  val stack1_hasThree = stack1_hasTwo.push(3)
  val stack1_hasTen = stack1_hasThree.push(10)
  println(stack1_hasTen.peek)
  println(stack1_hasTen.average)
  println(stack1_hasTen.average)
  val stack1_popped = stack1_hasTen.pop
  println(stack1_popped.empty)
  println()

  println("Test 2: ")
  val stack2 = new MegaStack[String]
  println(stack2.empty)
  val stack2_hasOne = stack2.push("One")
  val stack2_hasTwo = stack2_hasOne.push("Two")
  println(stack2_hasTwo.peek)
  //println(stack2_hasTwo.average)
  val stack2_popped = stack2_hasTwo.pop
  println(stack2_popped.empty)
  println()

  println("Test 3: ")
  val stack3 = new MegaStack[Double]
  val stack3_hasOne = stack3.push(2.3)
  val stack3_hasTwo = stack3_hasOne.push(6.6)
  val stack3_hasThree = stack3_hasTwo.push(10.4)
  println(stack3_hasThree.average)

}

