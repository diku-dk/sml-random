(* Random numbers with PCG32 *)

structure Pcg32 : RANDOM =
  struct

    val pcg32mult = 0wx5851f42d4c957f2d

    type generator = {state: Word64.word ref, inc: Word64.word ref}

    fun mask32 x = Word64.andb (x, 0wxFFFFFFFF)

    fun nextWord32 {state, inc} =
        let val oldstate = !state
            val xorshifted =
                mask32 (Word64.>>(Word64.xorb(Word64.>>(oldstate, 0w18),
                                              oldstate),
                                  0w27));
            val rot = mask32(Word64.>>(oldstate, 0w59))
            val x = Word64.orb(Word64.>>(xorshifted, Word.fromLarge rot),
                               (Word64.<<(xorshifted,
                                          Word.fromLarge(Word64.andb(Word64.+(Word64.notb rot, 0w1),
                                                                     0w31)))))
        in state := oldstate * pcg32mult + !inc;
           Word32.fromLarge(mask32(x))
        end

    fun newgenseed (seed: real) =
        let val initstate = Word64.fromInt (trunc seed)
            val initseq = 0w1
            val state = ref 0w0
            val inc = ref (Word64.orb (Word64.* (initseq, 0w2), 0w1))
            val rng = {state=state,
                       inc= inc}
        in nextWord32 rng;
           state := (!state + initstate);
           nextWord32 rng;
           rng
        end

    fun newgen () =
        newgenseed (Time.toReal(Time.now()))

    fun random rng =
        Real.fromLargeInt (Word32.toLargeInt (nextWord32 rng)) / 4294967295.0

    fun randomlist (n, rng) =
      let fun h 0 res = res
	    | h i res = h (i-1) (random rng :: res)
      in h n []
      end

    fun range (min, max) =
      if min >= max then raise Fail "Pcg32.range: empty range"
      else fn rng => floor (real min + random rng * real (max-min))

    fun rangelist (min, max) =
      if min >= max then raise Fail "Pcg32.rangelist: empty range"
      else fn (n, rng) =>
	   let fun h 0 res = res
		 | h i res = h (i-1) (floor (real min + random rng * real (max-min)) :: res)
	   in h n []
	   end

  end
