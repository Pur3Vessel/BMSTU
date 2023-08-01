class MultiplesSet private (pred: Int => Boolean, nums: Set[Int]) {

  val in = pred

  private val numsSet = nums

  def +(other: MultiplesSet): MultiplesSet = {
    val newSet = this.numsSet.union(other.numsSet)
    val newIn: Int => Boolean = x => this.in(x) || other.in(x)
    new MultiplesSet(newIn, newSet)
  }

  def *(other: MultiplesSet): MultiplesSet = {
    val newSet = this.numsSet.intersect(other.numsSet)
    val newIn: Int => Boolean = x => this.in(x) && other.in(x)
    new MultiplesSet(newIn, newSet)
  }

  def this(k: Int, nums: Array[Int]) = this(x => x % k == 0 && nums.contains(x), nums.filter(_ % k == 0).toSet)

  override def toString: String = this.numsSet.toString()
}


val arr1 = Array(3, 6, 9, 12, 13)
val arr2 = Array(3, 9, 15, 3, 4)
  
val set1 = new MultiplesSet(3, arr1)
val set2 = new MultiplesSet(3, arr2)

val unionSet = set1 + set2

val intersectSet = set1 * set2

val bool1 = unionSet.in(3)
val bool2 = unionSet.in(21)
val bool3 = intersectSet.in(15)

val arr3 = Array(5, 10, 15, 20, 35)
val arr4 = Array(14, 28, 42, 35,77)

val set3 = new MultiplesSet(5, arr3)
val set4 = new MultiplesSet(7, arr4)

val unionSet2 = set3 + set4
val intersectSet2 = set3 * set4
//println(unionSet2.numsSet.getClass)

val bool4 = set3.in(20)
val bool5 = unionSet2.in(42)
val bool6 = unionSet2.in(10)
val bool7 = intersectSet2.in(35)