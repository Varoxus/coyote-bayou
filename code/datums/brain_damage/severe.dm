//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Patient is completely unable to speak."
	scan_desc = "extensive damage to the brain's speech center"
	gain_text = span_warning("You forget how to speak!")
	lose_text = span_notice("You suddenly remember how to speak.")

/datum/brain_trauma/severe/mute/on_gain()
	ADD_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/mute/on_lose()
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/aphasia
	name = "Aphasia"
	desc = "Patient is unable to speak or understand any language."
	scan_desc = "extensive damage to the brain's language center"
	gain_text = span_warning("You have trouble forming words in your head...")
	lose_text = span_notice("You suddenly remember how languages work.")

/datum/brain_trauma/severe/aphasia/on_gain()
	owner.add_blocked_language(subtypesof(/datum/language/) - /datum/language/aphasia, LANGUAGE_APHASIA)
	owner.grant_language(/datum/language/aphasia, TRUE, TRUE, LANGUAGE_APHASIA)
	..()

/datum/brain_trauma/severe/aphasia/on_lose()
	owner.remove_blocked_language(subtypesof(/datum/language/), LANGUAGE_APHASIA)
	owner.remove_language(/datum/language/aphasia, TRUE, TRUE, LANGUAGE_APHASIA)
	..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Patient's brain is no longer connected to its eyes."
	scan_desc = "extensive damage to the brain's occipital lobe"
	gain_text = span_warning("You can't see!")
	lose_text = span_notice("Your vision returns.")

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Patient's brain can no longer control part of its motor functions."
	scan_desc = "cerebral paralysis"
	var/paralysis_type
	var/list/paralysis_traits = list()
	//for descriptions

/datum/brain_trauma/severe/paralysis/New(specific_type)
	if(specific_type)
		paralysis_type = specific_type
	if(!paralysis_type)
		paralysis_type = pick("full","left","right","arms","legs","r_arm","l_arm","r_leg","l_leg")
	var/subject
	switch(paralysis_type)
		if("full")
			subject = "your body"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("left")
			subject = "the left side of your body"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_L_LEG)
		if("right")
			subject = "the right side of your body"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_R_LEG)
		if("arms")
			subject = "your arms"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
		if("legs")
			subject = "your legs"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("r_arm")
			subject = "your right arm"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM)
		if("l_arm")
			subject = "your left arm"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM)
		if("r_leg")
			subject = "your right leg"
			paralysis_traits = list(TRAIT_PARALYSIS_R_LEG)
		if("l_leg")
			subject = "your left leg"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG)

	gain_text = span_warning("You can't feel [subject] anymore!")
	lose_text = span_notice("You can feel [subject] again!")

/datum/brain_trauma/severe/paralysis/on_gain()
	..()
	for(var/X in paralysis_traits)
		ADD_TRAIT(owner, X, "trauma_paralysis")
	owner.update_disabled_bodyparts()

/datum/brain_trauma/severe/paralysis/on_lose()
	..()
	for(var/X in paralysis_traits)
		REMOVE_TRAIT(owner, X, "trauma_paralysis")
	owner.update_disabled_bodyparts()

/datum/brain_trauma/severe/paralysis/paraplegic
	random_gain = FALSE
	paralysis_type = "legs"
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/spinesnapped
	random_gain = FALSE
	clonable = FALSE
	paralysis_type = "legs"
	resilience = TRAUMA_RESILIENCE_LOBOTOMY // It shouldn't fix severed spinal cords really, but there is no specific surgery for that yet.

/datum/brain_trauma/severe/narcolepsy
	name = "Narcolepsy"
	desc = "Patient may involuntarily fall asleep during normal activities."
	scan_desc = "traumatic narcolepsy"
	gain_text = span_warning("You have a constant feeling of drowsiness...")
	lose_text = span_notice("You feel awake and aware again.")

/datum/brain_trauma/severe/narcolepsy/on_life()
	..()
	if(owner.IsSleeping())
		return
	var/sleep_chance = 1
	if(owner.m_intent == MOVE_INTENT_RUN)
		sleep_chance += 2
	if(owner.drowsyness)
		sleep_chance += 3
	if(prob(sleep_chance))
		to_chat(owner, span_warning("You fall asleep."))
		owner.Sleeping(60)
	else if(!owner.drowsyness && prob(sleep_chance * 2))
		to_chat(owner, span_warning("You feel tired..."))
		owner.drowsyness += 10

/datum/brain_trauma/severe/monophobia
	name = "Monophobia"
	desc = "Patient feels sick and distressed when not around other people, leading to potentially lethal levels of stress."
	scan_desc = "monophobia"
	lose_text = span_notice("You feel like you could be safe on your own.")
	var/stress = 0

/datum/brain_trauma/severe/monophobia/on_gain()
	..()
	if(check_alone())
		to_chat(owner, span_warning("You feel really lonely..."))
	else
		to_chat(owner, span_notice("You feel safe, as long as you have people around you."))

/datum/brain_trauma/severe/monophobia/on_life()
	..()
	if(check_alone())
		stress = min(stress + 0.5, 100)
		if(stress > 30 && (prob(5)))
			stress_reaction()
	else
		stress = max(stress - 4, 0)

/datum/brain_trauma/severe/monophobia/proc/check_alone()
	//is... the owner of the pet blind..? because if yes... then they may not see the pet.
	if(HAS_TRAIT(owner, TRAIT_BLIND))
		return TRUE

	//firstly let's check if this pet is within our viewrange
	for(var/mob/M in oview(owner, 7))
		if(!isliving(M)) //ghosts ain't people
			continue
		if(M.is_monophobia_pet || M.ckey)
			return FALSE

	//secondly let's check if our pet is actually in our backpack
	var/obj/item/storage = owner.get_item_by_slot(SLOT_BACK)
	if(storage)  //Are we actually wearing a backpack?
		if(SEND_SIGNAL(storage, COMSIG_CONTAINS_STORAGE))  //Is the thing we are wearing on the back an actual storage item?
			if(storage.contents.len)  //if it has no items, don't even bother checking!
				for(var/obj/item/I in storage.contents)  //Is an animal hiding in our backpack????
					if(istype(I, /obj/item/clothing/head/mob_holder))
						return FALSE
	
	//thirdly let's actually check if the mob is being held in the hands
	for(var/obj/item/I in owner.held_items)  //Is an animal hiding on our hands????
		if(istype(I, /obj/item/clothing/head/mob_holder))
			return FALSE

	return TRUE

/datum/brain_trauma/severe/monophobia/proc/stress_reaction()
	if(owner.stat != CONSCIOUS)
		return

	var/high_stress = (stress > 60) //things get psychosomatic from here on
	switch(rand(1,5))
		if(1)
			if(!high_stress)
				to_chat(owner, span_warning("You feel sick..."))
			else
				to_chat(owner, span_warning("You feel really sick at the thought of being alone!"))
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living/carbon,vomit), high_stress), 50) //blood vomit if high stress
		if(2)
			if(!high_stress)
				to_chat(owner, span_warning("You can't stop shaking..."))
				owner.dizziness += 20
				owner.confused += 20
				owner.Jitter(20)
			else
				to_chat(owner, span_warning("You feel weak and scared! If only you weren't alone..."))
				owner.dizziness += 20
				owner.confused += 20
				owner.Jitter(20)
				owner.adjustStaminaLoss(50)

		if(3, 4)
			if(!high_stress)
				to_chat(owner, span_warning("You feel really lonely..."))
			else
				to_chat(owner, span_warning("You're going mad with loneliness!"))
				owner.hallucination += 30

		if(5)
			if(!high_stress)
				to_chat(owner, span_warning("Your heart skips a beat."))
				owner.adjustOxyLoss(8)

/datum/brain_trauma/severe/discoordination
	name = "Discoordination"
	desc = "Patient is unable to use complex tools or machinery."
	scan_desc = "extreme discoordination"
	gain_text = span_warning("You can barely control your hands!")
	lose_text = span_notice("You feel in control of your hands again.")
	random_gain = TRUE

/datum/brain_trauma/severe/discoordination/on_gain()
	ADD_TRAIT(owner, TRAIT_MONKEYLIKE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/discoordination/on_lose()
	REMOVE_TRAIT(owner, TRAIT_MONKEYLIKE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/pacifism
	name = "Traumatic Non-Violence"
	desc = "Patient is extremely unwilling to harm others in violent ways."
	scan_desc = "pacific syndrome"
	gain_text = span_notice("You feel oddly peaceful.")
	lose_text = span_notice("You no longer feel compelled to not harm.")

/datum/brain_trauma/severe/pacifism/on_gain()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/pacifism/on_lose()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

//ported from TG
/datum/brain_trauma/severe/hypnotic_stupor
	name = "Hypnotic Stupor"
	desc = "Patient is prone to episodes of extreme stupor that leaves them extremely suggestible."
	scan_desc = "oneiric feedback loop"
	gain_text = span_warning("You feel somewhat dazed.")
	lose_text = span_notice("You feel like a fog was lifted from your mind.")

/datum/brain_trauma/severe/hypnotic_stupor/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_stupor/on_life()
	..()
	if(prob(1) && !owner.has_status_effect(/datum/status_effect/trance))
		owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)

/datum/brain_trauma/severe/hypnotic_trigger
	name = "Hypnotic Trigger"
	desc = "Patient has a trigger phrase set in their subconscious that will trigger a suggestible trance-like state."
	scan_desc = "oneiric feedback loop"
	gain_text = span_warning("You feel odd, like you just forgot something important.")
	lose_text = span_notice("You feel like a weight was lifted from your mind.")
	random_gain = FALSE
	var/trigger_phrase = "Nanotrasen"

/datum/brain_trauma/severe/hypnotic_trigger/New(phrase)
	..()
	if(phrase)
		trigger_phrase = phrase

/datum/brain_trauma/severe/hypnotic_trigger/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_trigger/handle_hearing(datum/source, list/hearing_args)
	if(!owner.can_hear())
		return
	if(owner == hearing_args[HEARING_SPEAKER])
		return

	var/regex/reg = new("(\\b[REGEX_QUOTE(trigger_phrase)]\\b)","ig")

	if(findtext(hearing_args[HEARING_RAW_MESSAGE], reg))
		addtimer(CALLBACK(src,PROC_REF(hypnotrigger)), 10) //to react AFTER the chat message
		hearing_args[HEARING_RAW_MESSAGE] = reg.Replace(hearing_args[HEARING_RAW_MESSAGE], span_hypnophrase("*********"))

/datum/brain_trauma/severe/hypnotic_trigger/proc/hypnotrigger()
	to_chat(owner, span_warning("The words trigger something deep within you, and you feel your consciousness slipping away..."))
	owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)
