Require Import HoTT.Basics HoTT.Types HoTT.HIT.Truncations HoTT.Factorization.

(** Universal property of the image as stated in:
    "The join construction - Egbert Rijke - arXiv:1701.07538". *)


(** The image of a function f if { b : B & merely (hfiber f)}.
    It is defined in the file HIT.Truncations, and before in Modalities.Modality (for all truncation modalities). *)

Section Image.
  Context {A B} (f : A -> B).
  (** We define shorter names. They are accessibles through [Image.q], ... out of this file. *)
  Local Definition q : A -> himage f
    := factor1 (himage f).

  Local Definition i : himage f -> B
    := factor2 (himage f).

  Local Definition Q : i o q == f
    := fact_factors (himage f).

  Local Definition Hq : IsSurjection (q)
    := inclass1 (himage f).

  Local Definition Hi : IsEmbedding (i)
    := inclass2 (himage f).
End Image.


(** * Universal property of the image.   *)
Section ImageUP.
  (** Given a factorization of [f] as [q' o i'] where [i'] is an embedding, we want to characterize by a universal property the fact that this factorization give rise to the image of f. *)
  Context {Fs: Funext} {A B} (f : A -> B)
          I' (q' : A -> I') (i' : I' -> B)
          (Hi' : IsEmbedding i') (Q' : i' o q' == f).

(** The universal property. *)
  Definition image_UP
    := forall I'' (i'' : I'' -> B) (Hi'' : IsEmbedding i''),
      @IsEquiv (exists g, i'' o g == i') (exists q'', i'' o q'' == f)
               (fun X => (X.1 o q'; (fun x => X.2 (q' x) @ Q' x) : _)).

(** But, as i' is an embedding, the two types {g & i'' o g == i} and
    {q'' & i'' o q'' == f} are mere propositions. The universal property
    is thus equivalent to the following. *)
  Definition image_UP'
    := forall I'' (q'' : A -> I'') (i'' : I'' -> B) (Hi'' : IsEmbedding i'')
         (Q'' : i'' o q'' == f), exists g, i'' o g == i'.

  Definition image_UP_UP' : image_UP <-> image_UP'.
  Proof.
    split.
    - intros H I'' q'' i'' Hi'' Q''.
      apply (H I'' i'' Hi'').
      exact (q''; Q'').
    - intros H I'' i'' Hi''. serapply isequiv_iff_hprop.
      eapply TrM.RSU.inO_map_morphisms; eauto.
      eapply TrM.RSU.inO_map_morphisms; eauto.
      intros [q'' Q'']. apply (H _ _ _ Hi'' Q'').
  Defined.

(**  And the universal property is equivalent to the fact that the left map of
     the factorization is a surjection. *)

  (* We are forced to define the first direction separatly due to a subtle universe problem *)
  Lemma image_caract1 : image_UP -> IsSurjection q'.
  Proof.
    intro H; apply image_UP_UP' in H.
    apply BuildIsSurjection.
    specialize (H (himage q') (q q') (i' o i q')).
    destruct H as [X1 X2]. typeclasses eauto.
    exact (fun x => ap i' (Q q' x) @ Q' x).
    intro x.
    assert (e : i q' (X1 x) = x). {
      eapply (@equiv_inv _ _ _
                         (Fibrations.isequiv_ap_isembedding i' _ _)).
      exact (X2 x). }
    eapply Trunc_functor. 2: exact (X1 x).2.
    exact (fun w => (w.1 ; w.2 @ e)).
  Defined.

  Definition image_caract : image_UP <-> IsSurjection q'.
  Proof.
    split; intro H.
    - by apply image_caract1.
    - apply image_UP_UP'.
      intros I'' q'' i'' Hi'' Q''.
      eapply contr_inhabited_hprop.
      eapply TrM.RSU.inO_map_morphisms; eauto.
      eapply (equiv_sigT_coind (fun _ => I'') (fun x y => i'' y = i' x))^-1.
      intro x. eapply Trunc_rec. 2: exact (@center _ (H x)).
      intro w. refine (q'' w.1; Q'' w.1 @ (Q' w.1)^ @ ap i' w.2).
  Defined.

  (** Given a type satisfying the universal property, we can thus recover a
      factorization Surjection-Embedding. *)
  (* IsSurjection = TrM.RSU.IsConnMap (-1) *)
  (* IsEmbedding  = TrM.RSU.MapIn (-1) *)
  Definition image_UP_Factorization (H : image_UP)
    : Factorization (@TrM.RSU.IsConnMap (-1)) (@TrM.RSU.MapIn (-1)) f.
  Proof.
    refine (Build_Factorization (f:=f) I' q' i' Q' _ Hi').
    by apply image_caract1.
  Defined.

  (** And reusing the work on factorization systems, we have image unicity. *)
  Definition image_unicity (H : image_UP)
    : I' <~> himage f.
  Proof.
    pose (PF := path_factor (TrM.O_factsys (-1)) f).
    exact (path_intermediate (PF (image_UP_Factorization H) (himage f))).
  Defined.

End ImageUP.