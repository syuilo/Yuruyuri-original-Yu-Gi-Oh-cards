--歳納京子
function c1030.initial_effect(c)

	-- special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1030, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1030.spcon)
	c:RegisterEffect(e1)

	-- search1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1030, 1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c1030.target2)
	e2:SetOperation(c1030.operation2)
	c:RegisterEffect(e2)

	-- search2
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1030, 2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c1030.target3)
	e3:SetOperation(c1030.operation3)
	c:RegisterEffect(e3)

end

-- 結衣フィルター
function c1030.spfilter(c)
	-- 表側表示(=IsFaceup)かつ結衣(=1020)か
	return c:IsFaceup() and c:IsCode(1020)
end

function c1030.spcon(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1030.spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

-- 京子以外のゆるゆりキャラフィルター
function c1030.filter(c)
	-- ゆるゆりキャラクター(=0x186A0)かつ京子自身(=1030)ではない
	return c:IsSetCard(0x186A0) and not c:IsCode(1030) and c:IsAbleToHand()
end

-- <誰がなにを対象に発動するのか>
function c1030.target2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(c1030.filter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

-- <効果の内容>
function c1030.operation2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, c1030.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if g:GetCount() > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end

-- <誰がなにを対象に発動するのか>
function c1030.target3(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > -1
		and Duel.IsExistingMatchingCard(c1030.filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK)
end

-- <効果の内容>
function c1030.operation3(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, c1030.filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil, e, tp)
	if g:GetCount() > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
