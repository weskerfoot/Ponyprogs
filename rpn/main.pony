use "itertools"

class RPN
  fun operate(a : I64, b : I64, op : String) : I64 =>
    match op
      | "+" => return a + b
      | "*" => return a * b
      | "/" => return a / b
      | "-" => return a - b
    else
      0
    end

  fun calculate(exp : String, env : Env)? =>
    let tokens = this.tokenize(exp)
    let stack : Array[I64] = []

    for token in tokens do
      match token
        | let op : String =>
            try
              stack.push(this.operate(stack.pop()?, stack.pop()?, op))
            else
              env.out.print("Error: stack underflow, exiting")
              return
            end

        | let n : I64 =>
            stack.push(n)
      end
    end

    env.out.print(stack.apply(0)?.string())

    None

  fun tokenize(exp : String) : Iter[(I64 | String)] =>
    // We use a union type since read_int returns (I64, USize), and we want I64 | String
    Iter[String](exp.split(" ").values())
      .filter({
        (c) => (c != "") and (c != "\t") and (c != "\n")
      })
      .map[(I64 | String)]({
        (n) =>
          try
            // ? indicates it could return an exception
            match n.read_int[I64]() ?
              // returns the character if no int was found
              | (0, 0) => n
              | (let n' : I64, let s : USize) => n'
            end
          else
            n
          end
      })

  new val create() =>
    // Make the RPN class a val
    // This means the instance is immutable
    // It can be safely aliased
    """
    """

actor Main
  new create(env : Env) =>
    let calc = RPN.create()
    let input : String = " ".join(Iter[String](env.args.values()).skip(1))

    try
      calc.calculate(input, env)?
    else
      None
    end
