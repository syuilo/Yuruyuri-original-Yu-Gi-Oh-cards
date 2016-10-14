--大天使アカリエル
--「大天使アカリエル」は自分フィールド上に１体しか表側表示で存在できない。
--①：このカードは戦闘では破壊されない。
--②：フィールドのカードを破壊する魔法・罠・モンスターの効果が発動した時、このカードをリリースして発動できる。その発動を無効にし破壊する。
--③：このカードの②の効果を適用したターンのエンドフェイズに発動できる。その効果を発動するためにリリースしたこのカードを墓地から特殊召喚する。
--④：１ターンに１度だけ、自分の墓地に存在する「ゆるゆり」キャラクター１人を自分フィールド上に特殊召喚できる。
function c100.initial_effect(c)

	-- 1体しか存在できない
	c:SetUniqueOnField(1, 1, 100)

	-- synchro summon
	aux.AddSynchroProcedure(c, nil, aux.NonTuner(nil), 1)
	c:EnableReviveLimit()

	-- battle indes
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetValue(c100.valcon)
	c:RegisterEffect(e1)

	-- Negate
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100, 2))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c100.e2condition)
	e2:SetCost(c100.e2cost)
	e2:SetTarget(c100.e2target)
	e2:SetOperation(c100.e2operation)
	c:RegisterEffect(e2)

	-- Revive
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100, 3))
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetTarget(c100.e3target)
	e3:SetOperation(c100.e3operation)
	c:RegisterEffect(e3)

	-- SpecialSummon
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100, 4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c100.e4target)
	e4:SetOperation(c100.e4operation)
	c:RegisterEffect(e4)

end

-- 戦闘の場合は破壊されない
function c100.valcon(e, re, r, rp)
	return bit.band(r, REASON_BATTLE) ~= 0
end

function c100.e2condition(e, tp, eg, ep, ev, re, r, rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE) -- 破壊する効果を持っているか(?)
		and Duel.GetChainInfo(ev - 1, CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex, tg, tc = Duel.GetOperationInfo(ev, CATEGORY_DESTROY)
	return ex and tg ~= nil and tc + tg:FilterCount(Card.IsOnField, nil) - tg:GetCount() > 0
end

function c100.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(), REASON_COST)
end

function c100.e2target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
	end
end

function c100.e2operation(e, tp, eg, ep, ev, re, r, rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg, REASON_EFFECT)
	end
	e:GetHandler():RegisterFlagEffect(100, RESET_EVENT + 0x1fe0000 + RESET_PHASE + PHASE_END, 0, 0)
end

function c100.e3target(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:GetFlagEffect(100) > 0
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function c100.e3operation(e, tp, eg, ep, ev, re, r, rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
	end
end

function c100.e4tgfilter(c, e, tp)
	return c:IsSetCard(0x186A0) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function c100.e4target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c100.e4tgfilter(chkc, e, tp) end
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingTarget(c100.e4tgfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, c100.e4tgfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function c100.e4operation(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
end
