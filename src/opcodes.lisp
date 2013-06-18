(in-package :6502)

(defasm adc (:docs "Add to Accumulator with Carry")
    ((#x61 6 2 indirect-x)
     (#x65 3 2 zero-page)
     (#x69 2 2 immediate)
     (#x6d 4 3 absolute)
     (#x71 5 2 indirect-y)
     (#x75 4 2 zero-page-x)
     (#x79 4 3 absolute-y)
     (#x7d 4 3 absolute-x))
  (let ((result (+ (cpu-ar cpu) (getter) (status-bit :carry))))
    (set-flags-if :carry (> result #xff)
                  :overflow (overflow-p result (cpu-ar cpu) (getter))
                  :negative (logbitp 7 result)
                  :zero (zerop (wrap-byte result)))
    (setf (cpu-ar cpu) (wrap-byte result))))

(defasm and (:docs "And with Accumulator")
    ((#x21 6 2 indirect-x)
     (#x25 3 2 zero-page)
     (#x29 2 2 immediate)
     (#x2d 4 3 absolute)
     (#x31 5 2 indirect-y)
     (#x35 4 2 zero-page-x)
     (#x39 4 3 absolute-y)
     (#x3d 4 3 absolute-x))
  (let ((result (setf (cpu-ar cpu) (logand (cpu-ar cpu) (getter)))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm asl (:docs "Arithmetic Shift Left" :raw-p t)
    ((#x06 5 2 zero-page)
     (#x0a 2 1 accumulator)
     (#x0e 6 3 absolute)
     (#x16 6 2 zero-page-x)
     (#x1e 7 3 absolute-x))
  (let* ((value (getter-mixed))
         (result (wrap-byte (ash value 1))))
    (set-flags-if :carry (logbitp 7 value)
                  :zero (zerop result)
                  :negative (logbitp 7 result))
    (setter result)))

(defasm bcc (:docs "Branch on Carry Clear" :track-pc nil)
    ((#x90 2 2 relative))
  (branch-if (zerop (status-bit :carry)) cpu))

(defasm bcs (:docs "Branch on Carry Set" :track-pc nil)
    ((#xb0 2 2 relative))
  (branch-if (plusp (status-bit :carry)) cpu))

(defasm beq (:docs "Branch if Equal" :track-pc nil)
    ((#xf0 2 2 relative))
  (branch-if (plusp (status-bit :zero)) cpu))

(defasm bit (:docs "Test Bits in Memory with Accumulator")
    ((#x24 3 2 zero-page)
     (#x2c 4 3 absolute))
  (let ((result (getter)))
    (set-flags-if :zero (zerop (logand (cpu-ar cpu) result))
                  :negative (logbitp 7 result)
                  :overflow (logbitp 6 result))))

(defasm bmi (:docs "Branch on Negative Result" :track-pc nil)
    ((#x30 2 2 relative))
  (branch-if (plusp (status-bit :negative)) cpu))

(defasm bne (:docs "Branch if Not Equal" :track-pc nil)
    ((#xd0 2 2 relative))
  (branch-if (zerop (status-bit :zero)) cpu))

(defasm bpl (:docs "Branch on Positive Result" :track-pc nil)
    ((#x10 2 2 relative))
  (branch-if (zerop (status-bit :negative)) cpu))

(defasm brk (:docs "Force Break")
    ((#x00 7 1 implied))
  (let ((pc (wrap-word (1+ (cpu-pc cpu)))))
    (stack-push-word pc cpu)
    (set-status-bit :break 1)
    (stack-push (cpu-sr cpu) cpu)
    (set-status-bit :interrupt 1)
    (setf (cpu-pc cpu) (get-word #xfffe))))

(defasm bvc (:docs "Branch on Overflow Clear" :track-pc nil)
    ((#x50 2 2 relative))
  (branch-if (zerop (status-bit :overflow)) cpu))

(defasm bvs (:docs "Branch on Overflow Set" :track-pc nil)
    ((#x70 2 2 relative))
  (branch-if (plusp (status-bit :overflow)) cpu))

(defasm clc (:docs "Clear Carry Flag")
    ((#x18 2 1 implied))
  (set-status-bit :carry 0))

(defasm cld (:docs "Clear Decimal Flag")
    ((#xd8 2 1 implied))
  (set-status-bit :decimal 0))

(defasm cli (:docs "Clear Interrupt Flag")
    ((#x58 2 1 implied))
  (set-status-bit :interrupt 0))

(defasm clv (:docs "Clear Overflow Flag")
    ((#xb8 2 1 implied))
  (set-status-bit :overflow 0))

(defasm cmp (:docs "Compare Memory with Accumulator")
    ((#xc1 6 2 indirect-x)
     (#xc5 3 2 zero-page)
     (#xc9 2 2 immediate)
     (#xcd 4 3 absolute)
     (#xd1 5 2 indirect-y)
     (#xd5 4 2 zero-page-x)
     (#xd9 4 3 absolute-y)
     (#xdd 4 3 absolute-x))
  (let ((result (- (cpu-ar cpu) (getter))))
    (set-flags-if :carry (not (minusp result))
                  :zero (zerop result)
                  :negative (logbitp 7 result))))

(defasm cpx (:docs "Compare Memory with X register")
    ((#xe0 2 2 immediate)
     (#xe4 3 2 zero-page)
     (#xec 4 3 absolute))
  (let ((result (- (cpu-xr cpu) (getter))))
    (set-flags-if :carry (not (minusp result))
                  :zero (zerop result)
                  :negative (logbitp 7 result))))

(defasm cpy (:docs "Compare Memory with Y register")
    ((#xc0 2 2 immediate)
     (#xc4 3 2 zero-page)
     (#xcc 4 3 absolute))
  (let ((result (- (cpu-yr cpu) (getter))))
    (set-flags-if :carry (not (minusp result))
                  :zero (zerop result)
                  :negative (logbitp 7 result))))

(defasm dec (:docs "Decrement Memory")
    ((#xc6 5 2 zero-page)
     (#xce 6 3 absolute)
     (#xd6 6 2 zero-page-x)
     (#xde 7 3 absolute-x))
  (let ((result (wrap-byte (1- (getter)))))
    (setter result)
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm dex (:docs "Decrement X register")
    ((#xca 2 1 implied))
  (let ((result (setf (cpu-xr cpu) (wrap-byte (1- (cpu-xr cpu))))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm dey (:docs "Decrement Y register")
    ((#x88 2 1 implied))
  (let ((result (setf (cpu-yr cpu) (wrap-byte (1- (cpu-yr cpu))))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm eor (:docs "Exclusive OR with Accumulator")
    ((#x41 6 2 indirect-x)
     (#x45 3 2 zero-page)
     (#x49 2 2 immediate)
     (#x4d 4 3 absolute)
     (#x51 5 2 indirect-y)
     (#x55 4 2 zero-page-x)
     (#x59 4 3 absolute-y)
     (#x5d 4 3 absolute-x))
  (let ((result (setf (cpu-ar cpu) (logxor (getter) (cpu-ar cpu)))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm inc (:docs "Increment Memory")
    ((#xe6 5 2 zero-page)
     (#xee 6 3 absolute)
     (#xf6 6 2 zero-page-x)
     (#xfe 7 3 absolute-x))
  (let ((result (wrap-byte (1+ (getter)))))
    (setter result)
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm inx (:docs "Increment X register")
    ((#xe8 2 1 implied))
  (let ((result (setf (cpu-xr cpu) (wrap-byte (1+ (cpu-xr cpu))))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm iny (:docs "Increment Y register")
    ((#xc8 2 1 implied))
  (let ((result (setf (cpu-yr cpu) (wrap-byte (1+ (cpu-yr cpu))))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm jmp (:docs "Jump Unconditionally" :raw-p t :track-pc nil)
    ((#x4c 3 3 absolute)
     (#x6c 5 3 indirect))
  (setf (cpu-pc cpu) (getter)))

(defasm jsr (:docs "Jump to Subroutine" :raw-p t :track-pc nil)
    ((#x20 6 3 absolute))
  (stack-push-word (wrap-word (1+ (cpu-pc cpu))) cpu)
  (setf (cpu-pc cpu) (getter)))

(defasm lda (:docs "Load Accumulator from Memory")
    ((#xa1 6 2 indirect-x)
     (#xa5 3 2 zero-page)
     (#xa9 2 2 immediate)
     (#xad 4 3 absolute)
     (#xb1 5 2 indirect-y)
     (#xb5 4 2 zero-page-x)
     (#xb9 4 3 absolute-y)
     (#xbd 4 3 absolute-x))
  (let ((result (setf (cpu-ar cpu) (getter))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm ldx (:docs "Load X register from Memory")
    ((#xa2 2 2 immediate)
     (#xa6 3 2 zero-page)
     (#xae 4 3 absolute)
     (#xb6 4 2 zero-page-y)
     (#xbe 4 3 absolute-y))
  (let ((result (setf (cpu-xr cpu) (getter))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm ldy (:docs "Load Y register from Memory")
    ((#xa0 2 2 immediate)
     (#xa4 3 2 zero-page)
     (#xac 4 3 absolute)
     (#xbc 4 3 absolute-x)
     (#xb4 4 2 zero-page-x))
  (let ((result (setf (cpu-yr cpu) (getter))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm lsr (:docs "Logical Shift Right" :raw-p t)
    ((#x46 5 2 zero-page)
     (#x4a 2 1 accumulator)
     (#x4e 6 3 absolute)
     (#x56 6 2 zero-page-x)
     (#x5e 7 3 absolute-x))
  (let* ((value (getter-mixed))
         (result (ash value -1)))
    (set-flags-if :carry (logbitp 0 value)
                  :zero (zerop result)
                  :negative (logbitp 7 result))
    (setter result)))

(defasm nop (:docs "No Operation")
    ((#xea 2 1 implied))
  nil)

(defasm ora (:docs "Bitwise OR with Accumulator")
    ((#x01 6 2 indirect-x)
     (#x05 3 2 zero-page)
     (#x09 2 2 immediate)
     (#x0d 4 3 absolute)
     (#x11 5 2 indirect-y)
     (#x15 4 2 zero-page-x)
     (#x19 4 3 absolute-y)
     (#x1d 4 3 absolute-x))
  (let ((result (setf (cpu-ar cpu) (logior (cpu-ar cpu) (getter)))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm pha (:docs "Push Accumulator")
    ((#x48 3 1 implied))
  (stack-push (cpu-ar cpu) cpu))

(defasm php (:docs "Push Processor Status")
    ((#x08 3 1 implied))
  (stack-push (logior (cpu-sr cpu) #x10) cpu))

(defasm pla (:docs "Pull Accumulator from Stack")
    ((#x68 4 1 implied))
  (let ((result (setf (cpu-ar cpu) (stack-pop cpu))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm plp (:docs "Pull Processor Status from Stack")
    ((#x28 4 1 implied))
  (let ((result (logior (stack-pop cpu) #x20)))
    (setf (cpu-sr cpu) (logandc2 result #x10))))

(defasm rol (:docs "Rotate Left" :raw-p t)
    ((#x2a 2 1 accumulator)
     (#x26 5 2 zero-page)
     (#x2e 6 3 absolute)
     (#x36 6 2 zero-page-x)
     (#x3e 7 3 absolute-x))
  (let* ((val (getter-mixed))
         (result (wrap-byte (rotate-byte val 1 cpu))))
    (setter result)
    (set-flags-if :carry (logbitp 7 val)
                  :zero (zerop result)
                  :negative (logbitp 7 result))))

(defasm ror (:docs "Rotate Right" :raw-p t)
    ((#x66 5 2 zero-page)
     (#x6a 2 1 accumulator)
     (#x6e 6 3 absolute)
     (#x76 6 2 zero-page-x)
     (#x7e 7 3 absolute-x))
  (let* ((val (getter-mixed))
         (result (wrap-byte (rotate-byte val -1 cpu))))
    (setter result)
    (set-flags-if :carry (logbitp 0 val)
                  :zero (zerop result)
                  :negative (logbitp 7 result))))

(defasm rti (:docs "Return from Interrupt")
    ((#x40 6 1 implied))
  (setf (cpu-sr cpu) (logior (stack-pop cpu) #x20))
  (setf (cpu-pc cpu) (stack-pop-word cpu)))

(defasm rts (:docs "Return from Subroutine" :track-pc nil)
    ((#x60 6 1 implied))
  (setf (cpu-pc cpu) (1+ (stack-pop-word cpu))))

(defasm sbc (:docs "Subtract from Accumulator with Carry")
    ((#xe1 6 2 indirect-x)
     (#xe5 3 2 zero-page)
     (#xe9 2 2 immediate)
     (#xed 4 3 absolute)
     (#xf1 5 2 indirect-y)
     (#xf5 4 2 zero-page-x)
     (#xf9 4 3 absolute-y)
     (#xfd 4 3 absolute-x))
  (flet ((flip-bit (position x) (logxor (expt 2 position) x)))
    (let* ((val (getter))
           (result (- (cpu-ar cpu) val (flip-bit 0 (status-bit :carry)))))
      (set-flags-if :zero (zerop (wrap-byte result))
                    :overflow (overflow-p result (cpu-ar cpu) (flip-bit 7 val))
                    :negative (logbitp 7 result)
                    :carry (not (minusp result)))
      (setf (cpu-ar cpu) (wrap-byte result)))))

(defasm sec (:docs "Set Carry Flag")
    ((#x38 2 1 implied))
  (set-status-bit :carry 1))

(defasm sed (:docs "Set Decimal Flag")
    ((#xf8 2 1 implied))
  (set-status-bit :decimal 1))

(defasm sei (:docs "Set Interrupt Flag")
    ((#x78 2 1 implied))
  (set-status-bit :interrupt 1))

(defasm sta (:docs "Store Accumulator" :raw-p t)
    ((#x81 6 2 indirect-x)
     (#x85 3 2 zero-page)
     (#x8d 4 3 absolute)
     (#x91 6 2 indirect-y)
     (#x95 4 2 zero-page-x)
     (#x99 5 3 absolute-y)
     (#x9d 5 3 absolute-x))
  (setter (cpu-ar cpu)))

(defasm stx (:docs "Store X register" :raw-p t)
    ((#x86 3 2 zero-page)
     (#x8e 4 3 absolute)
     (#x96 4 2 zero-page-y))
  (setter (cpu-xr cpu)))

(defasm sty (:docs "Store Y register" :raw-p t)
    ((#x84 3 2 zero-page)
     (#x8c 4 3 absolute)
     (#x94 4 2 zero-page-x))
  (setter (cpu-yr cpu)))

(defasm tax (:docs "Transfer Accumulator to X register")
    ((#xaa 2 1 implied))
  (let ((result (setf (cpu-xr cpu) (cpu-ar cpu))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm tay (:docs "Transfer Accumulator to Y register")
    ((#xa8 2 1 implied))
  (let ((result (setf (cpu-yr cpu) (cpu-ar cpu))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm tsx (:docs "Transfer Stack Pointer to X register")
    ((#xba 2 1 implied))
  (let ((result (setf (cpu-xr cpu) (cpu-sp cpu))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm txa (:docs "Transfer X register to Accumulator")
    ((#x8a 2 1 implied))
  (let ((result (setf (cpu-ar cpu) (cpu-xr cpu))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))

(defasm txs (:docs "Transfer X register to Stack Pointer")
    ((#x9a 2 1 implied))
  (setf (cpu-sp cpu) (cpu-xr cpu)))

(defasm tya (:docs "Transfer Y register to Accumulator")
    ((#x98 2 1 implied))
  (let ((result (setf (cpu-ar cpu) (cpu-yr cpu))))
    (set-flags-if :zero (zerop result) :negative (logbitp 7 result))))
